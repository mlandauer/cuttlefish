namespace :cuttlefish do
  desc "Start the Cuttlefish SMTP server"
  task :smtp do
    # Eek
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "bin", "cuttlefish_smtp_server"))
  end
end