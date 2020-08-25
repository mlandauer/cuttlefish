# frozen_string_literal: true

source "https://rubygems.org"

gem "dotenv-rails"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "5.2.4.3"

gem "pg"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "sass-rails"
  # Don't upgrade to Bootstrap 3. It's already responsive, for example, so
  # there's a bunch of things we need to do for the upgrade
  gem "bootstrap-sass", "~> 2.0"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem "therubyracer", platforms: :ruby

  gem "less-rails"
  gem "uglifier"
end

gem "jquery-rails"

gem "jbuilder"

gem "eventmachine"
gem "sidekiq"
gem "sinatra", require: nil

gem "batch-loader"
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
gem "graphql"
gem "graphql-client"
gem "graphql-errors"
gem "graphql-guard"
gem "gravatar_image_tag"
gem "haml-rails"
gem "honeybadger"
gem "syslog_protocol"
gem "will_paginate"
# Need commit c9331088146e456a69bd6e94298c80d09be3ee74
gem "formtastic-bootstrap",
    git: "https://github.com/mjbellantoni/formtastic-bootstrap.git",
    ref: "f86eaef93bea0a06879b3977d7554864964a623f"
gem "haml-coderay"
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

group :development do
  gem "capistrano", "~> 2"
  gem "faker", git: "https://github.com/stympy/faker.git", branch: "master"
  gem "graphiql-rails"
  gem "rack-mini-profiler"
  gem "rubocop", require: false
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
