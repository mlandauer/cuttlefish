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
end