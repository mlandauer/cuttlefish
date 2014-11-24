# Archive (and restore) emails in the database
class Archiving
  # Archive all the emails for a particular date (in UTC)
  # TODO Check that we're not trying to archive today's email
  def self.archive(date)
    t0 = date.to_datetime
    t1 = t0.next_day
    deliveries = Delivery.where(created_at: t0..t1).includes(:links, :click_events, :open_events, :address, :postfix_log_lines, {:email => [:from_address, :app]})
    if deliveries.empty?
      puts "Nothing to archive for #{date}"
    else
      FileUtils.mkdir_p("db/archive")
      puts "Archiving #{date}..."
      # TODO bzip2 gives better compression but I had trouble with the Ruby gem for it
      Zlib::GzipWriter.open("db/archive/#{date}.tar.gz") do |gzip|
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
      puts "Removing archived data from database for #{date}..."
      deliveries.find_each do |delivery|
        delivery.destroy
      end
    end
  end

  def self.unarchive(date)
    Zlib::GzipReader.open("db/archive/#{date}.tar.gz") do |gzip|
      Archive::Tar::Minitar::Reader.open(gzip) do |reader|
        reader.each do |entry|
          deserialise(entry.read)
          # We are intentionally not decrementing the archived_deliveries_count
        end
      end
    end
  end

  def self.serialise(delivery)
    ActionController::Base.new.render_to_string(partial: "deliveries/delivery.json.jbuilder", locals: {delivery: delivery})
  end

  def self.deserialise(text)
    data = JSON.parse(text, symbolize_names: true)
    puts "Reloading delivery #{data[:id]}..."
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
end
