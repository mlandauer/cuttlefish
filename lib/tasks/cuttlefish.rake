require File.expand_path(File.join(File.dirname(__FILE__), "..", "cuttlefish_control"))

namespace :cuttlefish do
  desc "Start the Cuttlefish SMTP server"
  task :smtp do
    CuttlefishControl.smtp_start
  end

  desc "Start the Postfix mail log sucker"
  task :log => :environment do
    CuttlefishControl.log_start
  end

  desc "Update status of email (if it is out of sync)"
  task :update_status => :environment do
    Email.all.each {|email| email.update_status! }
  end

  desc "Archive all emails from a particular date (e.g. 2014-05-01)"
  task :archive, [:date1, :date2] => :environment do |t, args|
    args.with_defaults(:date2 => args.date1)
    (Date.parse(args.date1)..Date.parse(args.date2)).each do |date|
      Archiving.archive(date)
    end
  end
end
