smtp: bundle exec rake cuttlefish:smtp
log: bundle exec rake cuttlefish:log
sidekiq: bundle exec sidekiq
web: bundle exec rails s
# This is actually currently running the whole application.
# TODO: Make it just run the api
api: bundle exec rails s --port=5400 --pid=tmp/pids/api.pid
