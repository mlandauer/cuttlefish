require File.expand_path(File.join(File.dirname(__FILE__), "..", "cuttlefish_control"))

namespace :cuttlefish do
  desc "Start the Cuttlefish SMTP server"
  task :smtp do
    CuttlefishControl.smtp_start
  end
end