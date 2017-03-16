source 'https://rubygems.org'

gem 'dotenv-deployment'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'

gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  # Don't upgrade to Bootstrap 3. It's already responsive, for example, so there's a bunch
  # of things we need to do for the upgrade
  gem 'bootstrap-sass', '~> 2.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.3.0'
  gem "less-rails"
end

gem 'jquery-rails'

gem 'jbuilder'

gem "eventmachine"
gem 'sidekiq'
gem 'sinatra', :require => nil

gem 'foreman'
gem 'haml-rails'
# Use pull request that has needed Rails 4 improvements https://github.com/pkurek/flatui-rails/pull/25
gem 'flatui-rails', github: 'iffyuva/flatui-rails', ref: '3d3c423'
gem 'font-awesome-rails'
gem "file-tail"
gem 'syslog_protocol'
gem "will_paginate"
gem "dnsbl-client"
gem "devise"
gem 'devise_invitable'
gem 'gravatar_image_tag'
gem "formtastic"
# Need commit c9331088146e456a69bd6e94298c80d09be3ee74
gem 'formtastic-bootstrap', git: "https://github.com/mjbellantoni/formtastic-bootstrap.git", ref: "f86eaef93bea0a06879b3977d7554864964a623f"
gem 'factory_girl_rails'
gem 'haml-coderay'
gem 'nokogiri'
gem 'google-analytics-rails'
gem 'premailer'
gem "skylight"
gem "archive-tar-minitar"
gem "pundit"
gem "friendly_id"
gem "user_agent_parser"
gem "mail_form"
gem 'newrelic_rpm'
gem 'honeybadger'
gem 'dkim'
gem 'fog'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'

group :development do
  # Webrick gives us annoying warnings "could not determine content-length of response body"
  gem "thin"
  gem 'guard'
  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false
  gem 'guard-livereload'
  gem "rack-livereload"
  gem "guard-rspec"
  gem 'rack-mini-profiler'
  gem "spring"
  gem "spring-commands-rspec"
  gem "capistrano", "~> 2"
  gem 'rvm-capistrano', ">= 1.5.6", require: false
  # Newer versions don't support Ruby 2.1. Remove this when we upgrade Ruby
  gem "listen", "~> 2"
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'climate_control'
  gem "vcr"
  gem "webmock"
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'capybara'
  # PhantomJS currently has some issues with font loading. So, for the time being
  # using selenium instead
  #gem 'poltergeist'
  gem 'selenium-webdriver'
  # For resizing screenshots
  gem 'rmagick'
end
