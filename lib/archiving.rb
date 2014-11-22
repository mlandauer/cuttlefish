# Archive (and restore) emails in the database
class Archiving
  # Archive all the emails for a particular date (in UTC)
  # TODO Check that we're not trying to archive today's email
  def self.archive(date)
    t0 = date.to_datetime
    t1 = t0.next_day
    deliveries = Delivery.where(created_at: t0..t1).includes(:links, :click_events, :open_events, :address, :postfix_log_lines, {:email => [:from_address, :app]})

    # Compress with gzip
    # TODO bzip2 gives better compression but I had trouble with the Ruby gem for it
    # Zlib::GzipWriter.open("db/archive/#{date}.json.gz") do |f|
    #   f.write ActionController::Base.new.render_to_string(partial: "deliveries/deliveries.json.jbuilder", locals: {deliveries: deliveries})
    # end
    FileUtils.mkdir_p("db/archive")
    File.open("db/archive/#{date}.tar", "w") do |a|
      Archive::Tar::Minitar::Writer.open(a) do |writer|
        deliveries.find_each do |delivery|
          content = ActionController::Base.new.render_to_string(partial: "deliveries/delivery.json.jbuilder", locals: {delivery: delivery})
          writer.add_file_simple("#{date}/#{delivery.id}.json", size: content.length, mode: 0600 ) {|f| f.write content}
        end
      end
    end
  end
end
