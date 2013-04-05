require File.expand_path(File.join(File.dirname(__FILE__), "..", "cuttlefish_control"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "postfix_log"))

namespace :cuttlefish do
  desc "Start the Cuttlefish SMTP server"
  task :smtp do
    CuttlefishControl.smtp_start
  end

  desc "Start the Postfix mail log sucker"
  task :log do
    PostfixLog::tail
  end
end