# frozen_string_literal: true

source "https://rubygems.org"

gem "dotenv-rails"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.0"

gem "pg"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # Locking sass-rails for the time being to avoid having to upgrade sprockets from 3->4
  gem "sass-rails", "~> 5.0"
  # Don't upgrade to Bootstrap 3. It's already responsive, for example, so
  # there's a bunch of things we need to do for the upgrade
  gem "bootstrap-sass", "~> 2.0"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # IMPORTANT NOTE - as a short term workaround we have installed nodejs on the cuttlefish server
  # to be the js runtime. This is because we're still using capistrano 2 which is now not working
  # well with the newer bundler version which means that it can't find therubyracer. Ugh
  # TODO: Upgrade capistrano 2 -> 3
  gem "therubyracer", platforms: :ruby

  # Problem with compiling assets in production otherwise
  gem "less-rails", "4.0.0"
  gem "uglifier"
end

gem "jquery-rails"

gem "jbuilder"

gem "eventmachine"
# We're using a very old version of redis currently which forces us stay at version 5 of sidekiq
# TODO: Update redis
gem "sidekiq", "~> 5.1"
gem "sinatra", require: nil

gem "batch-loader"
gem "coderay"
gem "devise"
gem "devise_invitable"
gem "dkim"
gem "dnsbl-client"
gem "factory_bot_rails"
gem "file-tail"
gem "foreman"
gem "formtastic"
# Use pull request that has needed Rails 4 improvements https://github.com/pkurek/flatui-rails/pull/25
gem "flatui-rails", git: "https://github.com/iffyuva/flatui-rails.git",
                    ref: "3d3c423"
gem "fog-aws"
gem "font-awesome-rails"
gem "friendly_id"
gem "google-analytics-rails"
# Looks like it's a bit of a pain to upgrade graphql. So just locking
# the version for the time being
# TODO: Upgrade to at least 1.11.7 so we can upgrade ruby to 3.0
gem "graphql", "~> 1.12.0"
# And the same for graphql-client though I'm guessing that should be easier to upgrade than graphql
gem "graphql-client", "~> 0.16.0"
gem "graphql-guard"
gem "haml-rails"
gem "honeybadger"
gem "syslog_protocol"
gem "will_paginate"
# Need commit c9331088146e456a69bd6e94298c80d09be3ee74
gem "formtastic-bootstrap",
    git: "https://github.com/mjbellantoni/formtastic-bootstrap.git",
    ref: "f86eaef93bea0a06879b3977d7554864964a623f"
gem "minitar"
gem "newrelic_rpm"
gem "nokogiri"
gem "premailer"
gem "pundit"
gem "user_agent_parser"
gem "virtus"

# For doing the webhooks to external sites
gem "rest-client"

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'

# We want to be able to use rack-mini-profiler in production
gem "rack-mini-profiler"

# For authorization with json web tokens
gem "jwt"

# For generating ssl certificates for custom tracking domains
gem "acme-client"

group :development do
  gem "capistrano", "~> 2"
  gem "faker"
  gem "graphiql-rails"
  gem "rubocop", require: false
  gem "rubocop-graphql", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rvm-capistrano", ">= 1.5.6", require: false
  gem "spring"
  gem "spring-commands-rspec"
  # Webrick gives us annoying warnings "could not determine content-length
  # of response body"
  gem "thin"

  gem "guard"
  gem "guard-rspec"
  gem "listen"
  gem "rb-fchange", require: false
  gem "rb-fsevent", require: false
  gem "rb-inotify", require: false
  gem "ruby_gntp"
  gem "terminal-notifier"
  gem "terminal-notifier-guard"
end

group :test do
  gem "climate_control"
  gem "coveralls", require: false
  gem "database_cleaner"
  gem "rails-controller-testing"
  gem "vcr"
  gem "webmock"
end

group :development, :test do
  gem "capybara"
  gem "rspec-activemodel-mocks"
  gem "rspec-rails"
  gem "selenium-webdriver"
  # For resizing screenshots
  gem "rmagick"
end
