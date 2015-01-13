# Doing this so that .delay doesn't conflict with that provided by delayed_job
Sidekiq.remove_delay!
