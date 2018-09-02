# Archive (and restore) emails in the database
class Archiving
  # Archive all the emails for a particular date (in UTC)
  # TODO Check that we're not trying to archive today's email
  def self.archive(date, noisy = true)
    t0 = date.to_datetime
    t1 = t0.next_day
    deliveries = Delivery.where(created_at: t0..t1).includes(:links, :click_events, :open_events, :address, :postfix_log_lines, {:email => [:from_address, :app]})
    if deliveries.empty?
      puts "Nothing to archive for #{date}" if noisy
    else
      FileUtils.mkdir_p(archive_directory)

      puts "Archiving #{date}..." if noisy
      # TODO bzip2 gives better compression but I had trouble with the Ruby gem for it
      Zlib::GzipWriter.open(archive_file_path_for(date)) do |gzip|
        Archive::Tar::Minitar::Writer.open(gzip) do |writer|
          # Get all the apps for these deliveries
          apps = App.find(Delivery.where(created_at: t0..t1).joins(:email).group(:app_id).pluck(:app_id))
          apps.each do |app|
            app_deliveries = Delivery.joins(:email).where(created_at: t0..t1, emails: {app_id: app.id}).includes(:links, :click_events, :open_events, :address, :postfix_log_lines, {:email => [:from_address, :app]})
            app_deliveries.find_each do |delivery|
             content = serialise(delivery)
             writer.add_file_simple("#{date}/#{delivery.id}.json", size: content.length, mode: 0600 ) {|f| f.write content}
            end
            # Doing one increment per app rather than per delivery
            app.increment!(:archived_deliveries_count, app_deliveries.count)
          end
        end
      end

      puts "Removing archived data from database for #{date}..." if noisy
      deliveries.find_each do |delivery|
        delivery.destroy
      end

      if copy_to_s3(date)
        puts "Removing local file #{archive_filename_for(date)} copied to S3..." if noisy
        File.delete(archive_file_path_for(date))
      else
        puts "Keeping file #{archive_filename_for(date)} as it wasn't copied to S3" if noisy
      end
    end
  end

  def self.unarchive(date)
    Zlib::GzipReader.open(archive_file_path_for(date)) do |gzip|
      Archive::Tar::Minitar::Reader.open(gzip) do |reader|
        reader.each do |entry|
          deserialise(entry.read)
          # We are intentionally not decrementing the archived_deliveries_count
        end
      end
    end
  end

  def self.serialise(delivery)
    ActionController::Base.new.render_to_string(
      partial: "deliveries/delivery.json.jbuilder",
      locals: {delivery: delivery}
    )
  end

  def self.deserialise(text)
    data = JSON.parse(text, symbolize_names: true)
    #puts "Reloading delivery #{data[:id]}..."
    # Create app if necessary
    App.create(data[:app]) if App.find(data[:app][:id]).nil?

    # Create email if necessary
    if Email.find(data[:email_id]).nil?
      Email.create(
      id: data[:email_id],
      from_address_id: data[:from_address][:id],
      subject: data[:subject],
      data_hash: data[:data_hash],
      app_id: data[:app][:id]
      )
    end
    delivery = Delivery.create(
    id: data[:id],
    address_id: data[:to_address][:id],
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
      delivery_link = delivery.delivery_links.create(link_id: link_data[:id])
      link_data[:click_events].each do |click_event_data|
        delivery_link.click_events.create(click_event_data)
      end
    end
    data[:tracking][:postfix_log_lines].each do |postfix_log_line_data|
      delivery.postfix_log_lines.create(postfix_log_line_data)
    end
    delivery
  end

  def self.copy_to_s3(date, noisy = true)
    if s3_bucket = ENV["S3_BUCKET"]
      puts "Copying #{archive_filename_for(date)} to S3 bucket #{s3_bucket}..." if noisy

      s3_connection = Fog::Storage.new(fog_storage_details)
      directory = s3_connection.directories.get(s3_bucket)
      directory.files.create(
        key: "#{date}.tar.gz",
        body: File.open(archive_file_path_for(date)),
      )
    else
      puts "Skipped upload of #{archive_filename_for(date)} because S3 access not configured" if noisy
    end
  end

  def self.archive_directory
    "db/archive"
  end

  def self.archive_filename_for(date)
    "#{date}.tar.gz"
  end

  def self.archive_file_path_for(date)
    "#{archive_directory}/#{archive_filename_for(date)}"
  end

  def self.fog_storage_details
    details = {
      provider: "AWS",
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    }
    details.merge!(region: ENV["AWS_REGION"]) if ENV["AWS_REGION"]
    details
  end
end
