source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.6'

# For the time being we'll keep sqlite and mysql both around so we can switch
# between them for development / production whatever. Not good in the long run but
# okay in the short term
#gem 'sqlite3'
gem 'mysql2'

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

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

gem "eventmachine"
gem 'delayed_job_active_record', "~> 4.0.0.beta1"
gem 'foreman'
gem 'haml-rails'
# Use pull request that has needed Rails 4 improvements https://github.com/pkurek/flatui-rails/pull/25
gem 'flatui-rails', github: 'iffyuva/flatui-rails', ref: '3d3c423'
gem 'font-awesome-sass-rails'
gem "file-tail"
gem 'syslog_protocol'
gem "will_paginate"
gem "dnsbl-client"
gem "devise"
gem 'devise_invitable'
gem 'gravatar_image_tag'
# Some rails 4 support (as of db89a982424d5e4dc0d784ae5cb6f1335fe68cd1) not yet officially released
gem "formtastic", git: "https://github.com/justinfrench/formtastic.git"
# Need commit c9331088146e456a69bd6e94298c80d09be3ee74
gem 'formtastic-bootstrap', git: "https://github.com/mjbellantoni/formtastic-bootstrap.git"
gem "net-dns"
gem "rails-settings-cached"
gem 'factory_girl_rails'
gem 'haml-coderay'
gem 'nokogiri'
gem 'google-analytics-rails'

# Deployment bits and bobs
# Later versions cause issues with backing up assets manifests file to release directory
# TODO: Fix this
gem "capistrano", "2.13.5"
gem 'rvm-capistrano'
gem 'newrelic_rpm'
gem 'honeybadger'

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
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  # PhantomJS currently has some issues with font loading. So, for the time being
  # using selenium instead
  #gem 'poltergeist'
  gem 'selenium-webdriver'
  # For resizing screenshots
  gem 'rmagick'
end
