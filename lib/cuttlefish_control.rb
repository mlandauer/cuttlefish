require File.expand_path File.join(File.dirname(__FILE__), 'cuttlefish_smtp_server')

module CuttlefishControl
  def self.smtp_start
    # Hardcoded to the development environment for the time being
    environment = "development"
    host = "127.0.0.1"
    port = 2525
    number_of_connections = 4

    # For the benefit of foreman
    $stdout.sync = true

    activerecord_config = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')))
    ActiveRecord::Base.establish_connection(activerecord_config[environment])

    server = CuttlefishSmtpServer.new(port, host, number_of_connections)
    server.audit = true
    server.start

    puts "My eight arms and two tentacles are quivering in anticipation."
    puts "I'm listening for emails via SMTP on #{host} port #{port}" 

    server.join
  end
end
