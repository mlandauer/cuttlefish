source 'https://rubygems.org'

gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.0'

gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  # Don't upgrade to Bootstrap 3. It's already responsive, for example, so there's a bunch
  # of things we need to do for the upgrade
  gem 'bootstrap-sass', '~> 2.0'

  gem 'uglifier'
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
gem 'flatui-rails', git: 'https://github.com/iffyuva/flatui-rails.git', ref: '3d3c423'
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
gem 'factory_bot_rails'
gem 'haml-coderay'
gem 'nokogiri'
gem 'google-analytics-rails'
gem 'premailer'
gem "minitar"
gem "pundit"
gem "friendly_id"
gem "user_agent_parser"
gem "mail_form"
gem 'newrelic_rpm'
gem 'honeybadger'
gem 'dkim'
gem 'fog-aws'
gem 'graphql'
gem 'graphql-client'

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
  gem "listen"
  gem 'graphiql-rails'
  gem 'faker', git: 'https://github.com/stympy/faker.git', branch: 'master'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'climate_control'
  gem "vcr"
  gem "webmock"
  gem 'rails-controller-testing'
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
