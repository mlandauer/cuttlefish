# frozen_string_literal: true

# Archive (and restore) emails in the database
class Archiving
  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  # Archive all the emails for a particular date (in UTC)
  # TODO Check that we're not trying to archive today's email
  def archive(date, noisy: true)
    t0 = date.to_datetime
    t1 = t0.next_day
    deliveries = Delivery
                 .where(created_at: t0..t1)
                 .includes(
                   :links,
                   :click_events,
                   :open_events,
                   :address,
                   :postfix_log_lines,
                   email: %i[from_address app]
                 )
    if deliveries.empty?
      logger.info "Nothing to archive for #{date}" if noisy
    else
      FileUtils.mkdir_p(archive_directory)

      logger.info "Archiving #{date}..." if noisy
      # TODO: bzip2 gives better compression but I had trouble with the
      # Ruby gem for it
      Zlib::GzipWriter.open(archive_file_path_for(date)) do |gzip|
        Archive::Tar::Minitar::Writer.open(gzip) do |writer|
          # Get all the apps for these deliveries
          ids = Delivery.where(created_at: t0..t1).joins(:email)
                        .group(:app_id).pluck(:app_id)
          apps = App.find(ids)
          apps.each do |app|
            app_deliveries = Delivery.joins(:email)
                                     .where(
                                       created_at: t0..t1,
                                       emails: { app_id: app.id }
                                     )
                                     .includes(
                                       :links,
                                       :click_events,
                                       :open_events,
                                       :address,
                                       :postfix_log_lines,
                                       email: %i[from_address app]
                                     )
            app_deliveries.find_each do |delivery|
              content = serialise(delivery)
              writer.add_file_simple(
                "#{date}/#{delivery.id}.json",
                size: content.length,
                mode: 0o600
              ) { |f| f.write content }
            end
            # Doing one increment per app rather than per delivery
            app.increment!(:archived_deliveries_count, app_deliveries.count)
          end
        end
      end

      logger.info "Removing archived data from database for #{date}..." if noisy
      deliveries.find_each(&:destroy)

      if copy_to_s3(date)
        logger.info "Removing local file #{archive_filename_for(date)} copied to S3..." if noisy
        File.delete(archive_file_path_for(date))
      elsif noisy
        logger.info "Keeping file #{archive_filename_for(date)} as it wasn't copied to S3"
      end
    end
  end

  def unarchive(date)
    Zlib::GzipReader.open(archive_file_path_for(date)) do |gzip|
      Archive::Tar::Minitar::Reader.open(gzip) do |reader|
        reader.each do |entry|
          deserialise(entry.read)
          # We are intentionally not decrementing the archived_deliveries_count
        end
      end
    end
  end

  def serialise(delivery)
    ActionController::Base.new.render_to_string(
      partial: "deliveries/delivery.json.jbuilder",
      locals: { delivery: delivery }
    )
  end

  def deserialise(text)
    data = JSON.parse(text, symbolize_names: true)
    # puts "Reloading delivery #{data[:id]}..."
    # Create app if necessary
    App.create(data[:app]) if App.find(data[:app][:id]).nil?

    # Create email if necessary
    if Email.find_by(id: data[:email_id]).nil?
      email = Email.create(
        id: data[:email_id],
        from_address_id: data[:from_address][:id],
        subject: data[:subject],
        app_id: data[:app][:id],
        ignore_deny_list: data[:ignore_deny_list]
      )
      # To ensure that the correct value of data_hash gets written we
      # don't want the callbacks to get called
      email.update_column(:data_hash, data[:data_hash])
    end
    # When archiving the addresses are not deleted so we assume that the address is already
    # there when unarchiving.
    # However, we're going to be slightly more clever and check that the text value of the address
    # is correct and if it doesn't exist in the database at all we're going to recreate it
    address = Address.find_by(id: data[:to_address][:id])
    if address
      unless address.text == data[:to_address][:text]
        raise "Data for address with id #{address.id} does not match that in archive"
      end
    else
      address = Address.create!(id: data[:to_address][:id], text: data[:to_address][:text])
    end
    delivery = Delivery.create!(
      id: data[:id],
      address: address,
      sent: data[:sent],
      status: data[:status],
      created_at: data[:created_at],
      updated_at: data[:updated_at],
      open_tracked: data[:tracking][:open_tracked],
      postfix_queue_id: data[:tracking][:postfix_queue_id],
      email_id: data[:email_id]
    )
    data[:tracking][:open_events].each do |open_event_data|
      delivery.open_events.create(open_event_data)
    end
    data[:tracking][:links].each do |link_data|
      # Archiving doesn't destroy links so we could naively just assume they will be there when we unarchive.
      # However we're going to try to be slightly more clever and make sure that the right link data is set
      # and if it isn't in the database for some reason then we will recreate it
      link = Link.find_by(id: link_data[:id])
      if link
        raise "Data for link with id #{link.id} does not match that in archive" unless link.url == link_data[:url]
      else
        link = Link.create!(id: link_data[:id], url: link_data[:url])
      end
      delivery_link = delivery.delivery_links.create!(link: link)
      link_data[:click_events].each do |click_event_data|
        delivery_link.click_events.create(click_event_data)
      end
    end
    data[:tracking][:postfix_log_lines].each do |postfix_log_line_data|
      delivery.postfix_log_lines.create(postfix_log_line_data)
    end
    (data[:meta_values] || {}).each do |key, value|
      delivery.email.meta_values.create(key: key, value: value)
    end
    delivery
  end

  def copy_to_s3(date, noisy: true)
    if (s3_bucket = ENV["S3_BUCKET"])
      logger.info "Copying #{archive_filename_for(date)} to S3 bucket #{s3_bucket}..." if noisy

      s3_connection = Fog::Storage.new(fog_storage_details)
      directory = s3_connection.directories.get(s3_bucket)
      directory.files.create(
        key: "#{date}.tar.gz",
        body: File.open(archive_file_path_for(date))
      )
    elsif noisy
      logger.info "Skipped upload of #{archive_filename_for(date)} because S3 access not configured"
    end
  end

  def archive_directory
    "db/archive"
  end

  def archive_filename_for(date)
    "#{date}.tar.gz"
  end

  def archive_file_path_for(date)
    "#{archive_directory}/#{archive_filename_for(date)}"
  end

  def fog_storage_details
    details = {
      provider: "AWS",
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    }

    details[:region] = ENV["AWS_REGION"] if ENV["AWS_REGION"]
    details
  end
end
