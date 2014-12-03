require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

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

    # For bootstrap-sass gem
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.assets.precompile += %w(*.woff *.svg *.eot *.ttf)

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

    config.postfix_smtp_host = ENV["POSTFIX_SMTP_HOST"] || "localhost"
    config.postfix_smtp_port = ENV["POSTFIX_SMTP_PORT"] ? ENV["POSTFIX_SMTP_PORT"].to_i : 25

    config.cuttlefish_smtp_port = 2525
  end
end
