# Archive (and restore) emails in the database
class Archive
  # Archive all the emails for a particular date (in UTC)
  # TODO Check that we're not trying to archive today's email
  def self.archive(date)
    t0 = date.to_datetime
    t1 = t0.next_day
    # This is memory intensive as it loads everything into memory.
    # TODO Do this more sensibly so that it consumes less memory
    deliveries = Delivery.where(created_at: t0..t1).includes(:links, :click_events, :open_events, :address, :postfix_log_lines, {:email => [:from_address, :app]})

    FileUtils.mkdir_p("db/archive")
    # Compress with gzip
    # TODO bzip2 gives better compression but I had trouble with the Ruby gem for it
    Zlib::GzipWriter.open("db/archive/#{date}.json.gz") do |f|
      f.write ActionController::Base.new.render_to_string(partial: "deliveries/deliveries.json.jbuilder", locals: {deliveries: deliveries})
    end
  end
end
