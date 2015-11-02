# Stolen from https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = 1
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
bind        "tcp://#{ ENV['WEB_LISTEN'] || 'localhost' }:#{ENV['WEB_PORT'] || 3000}"
environment ENV['RACK_ENV']     || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
