Cuttlefish::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true

  # Send our own outgoing email through Cuttlefish
  config.action_mailer.smtp_settings = { :address => "localhost", :port => 2525 }

  config.middleware.insert_after(ActionDispatch::Static, Rack::LiveReload)

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  #####################################################
  # Cuttlefish specific configuration below here ONLY #
  #####################################################

  # In development send the mails to mailcatcher: http://mailcatcher.me/
  config.postfix_smtp_host = "localhost"
  config.postfix_smtp_port = 1025
end
