# frozen_string_literal: true

require File.expand_path(
  File.join(File.dirname(__FILE__), "..", "cuttlefish_control")
)

namespace :cuttlefish do
  desc "Start the Cuttlefish SMTP server"
  task :smtp do
    CuttlefishControl.new(Logger.new($stdout)).smtp_start
  end

  desc "Start the Postfix mail log sucker"
  task log: :environment do
    CuttlefishControl.new(Logger.new($stdout)).log_start
  end

  desc "Update status of email (if it is out of sync)"
  task update_status: :environment do
    Email.all.each(&:update_status!)
  end

  desc "Daily maintenance tasks to be run via cron job"
  task daily_tasks: %i[auto_archive remove_old_deny_listed_items]

  desc "Archive all emails created more than 3 months ago"
  task auto_archive: :environment do
    date_to_archive_until = 3.months.ago.utc.to_date
    date_of_oldest_email = Delivery.order(:created_at).first.created_at.utc.to_date

    if date_of_oldest_email < date_to_archive_until
      (date_of_oldest_email...date_to_archive_until).each do |date|
        Archiving.new.archive(date)
      end
    else
      puts "No emails created before #{date_to_archive_until} to archive"
    end
  end

  desc "Allow sending to addresses again that were deny listed more than 1 week ago"
  task remove_old_deny_listed_items: :environment do
    old_items = DenyList.where("updated_at < ?", 1.week.ago)
    puts "Removing #{old_items.count} items from the deny list..."
    old_items.destroy_all
  end

  desc "Archive all emails from a particular date (e.g. 2014-05-01)"
  task :archive, %i[date1 date2] => :environment do |_t, args|
    args.with_defaults(date2: args.date1)
    (Date.parse(args.date1)..Date.parse(args.date2)).each do |date|
      Archiving.new.archive(date)
    end
  end

  desc "Copy archive to S3 (if it was missed as part of the archive task)"
  task :copy_archive_to_s3, %i[date1 date2] => :environment do |_t, args|
    raise "S3 not configured" unless ENV["S3_BUCKET"]

    args.with_defaults(date2: args.date1)
    (Date.parse(args.date1)..Date.parse(args.date2)).each do |date|
      Archiving.new.copy_to_s3(date)
    end
  end

  # This is just a temporary task to export some semi-anonymised production
  # delivery event data that can be used to develop a filter to categorise
  # events into different types (e.g. incorrect email address, suspected spam,
  # etc..)
  task export_redacted_hard_bounce_delivery_events: :environment do
    require "csv"

    CSV.open("hard_bounce_delivery_events.csv", "w") do |csv|
      csv << ["dsn", "extended status"]
      PostfixLogLine.find_each do |log|
        if log.dsn_class == 5
          # We want to remove this address from the extended status
          address = log.delivery.address.text
          domain = address.split("@")[1]
          redacted = log.extended_status
                        .gsub(address, "foo@example.com")
                        .gsub(domain, "example.com")

          csv << [log.dsn, redacted]
        end
      end
    end
  end
end
