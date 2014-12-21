require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cuttlefish
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Sydney'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.autoload_paths += %W(#{config.root}/lib)

    # We only use the ip address to track open and click events. If the client forges the
    # the HTTP_CLIENT_IP header in the request by default rails will throw an exception
    # and drop the request. We're not to so picky.
    # Alternatively we could remove the HTTP_CLIENT_IP header in middleware and depend on
    # X-Forwarded-For header (which in our case is set by Varnish) for the ip address.
    # See http://writeheavy.com/2011/07/31/when-its-ok-to-turn-of-rails-ip-spoof-checking.html
    # For the time being we'll do the dumb thing and just accept the forged requests. The
    # worst that happens is we have a few wrong ip address on tracking events
    config.action_dispatch.ip_spoofing_check = false

    #####################################################
    # Cuttlefish specific configuration below here ONLY #
    #####################################################

    config.cuttlefish_domain = ENV["CUTTLEFISH_DOMAIN"] || "cuttlefish.io"
    # TODO Rename the certificate to generic name that doesn't include domain
    config.cuttlefish_domain_cert_chain_file =
      ENV["CUTTLEFISH_DOMAIN_CERT_CHAIN_FILE"] || "/etc/ssl/cuttlefish.oaf.org.au.pem"
    config.cuttlefish_domain_private_key_file =
      ENV["CUTTLEFISH_DOMAIN_PRIVATE_KEY_FILE"] || "/etc/ssl/private/cuttlefish.oaf.org.au.key"

    config.postfix_smtp_host = ENV["POSTFIX_SMTP_HOST"] || "localhost"
    config.postfix_smtp_port = ENV["POSTFIX_SMTP_PORT"] ? ENV["POSTFIX_SMTP_PORT"].to_i : 25

    config.cuttlefish_smtp_port = ENV["CUTTLEFISH_SMTP_PORT"] ? ENV["CUTTLEFISH_SMTP_PORT"].to_i : 2525

    config.secret_key_base = ENV["SECRET_KEY_BASE"]

    config.action_mailer.default_url_options = { host: config.cuttlefish_domain, protocol: "https" }

    config.cuttlefish_read_only_mode = !ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
    config.cuttlefish_hash_salt = ENV["CUTTLEFISH_HASH_SALT"]
    config.disable_ssl = !ENV["DISABLE_SSL"].nil?
    config.postfix_log_path = ENV["POSTFIX_LOG_PATH"] || "/var/log/mail/mail.log"
    config.devise_emails_from = ENV["DEVISE_EMAILS_FROM"] || "contact@oaf.org.au"
    # By default keep the full content of the last 100 emails per app
    config.max_no_emails_to_store = ENV["MAX_NO_EMAILS_TO_STORE"] ? ENV["MAX_NO_EMAILS_TO_STORE"].to_i : 100
    # The bounce and sender email addresses need to be on the cuttlefish_domain domain
    config.cuttlefish_bounce_email = ENV["CUTTLEFISH_BOUNCE_EMAIL"] || "bounces@cuttlefish.oaf.org.au"
    config.cuttlefish_sender_email = ENV["CUTTLEFISH_SENDER_EMAIL"] || "sender@cuttlefish.oaf.org.au"
    config.middleware.use Rack::LiveReload
  end
end
