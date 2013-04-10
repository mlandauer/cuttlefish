source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0.beta1'

# For the time being we'll keep sqlite and mysql both around so we can switch
# between them for development / production whatever. Not good in the long run but
# okay in the short term
gem 'sqlite3'
gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0.beta1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.0.3'
  gem "less-rails"
end

gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

gem "eventmachine"
gem 'delayed_job_active_record', "~> 4.0.0.beta1"
gem 'foreman'
gem 'haml-rails'
gem "twitter-bootstrap-rails"
gem "file-tail"
gem 'syslog_protocol'
gem "will_paginate"
gem 'bootstrap-will_paginate'
gem "dnsbl-client"

# Deployment bits and bobs
gem "capistrano"
gem 'rvm-capistrano'
gem 'newrelic_rpm'

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
end

group :test do
  gem 'coveralls', require: false
end

group :development, :test do
  gem 'rspec-rails'
end