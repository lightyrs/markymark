web: bundle exec rails server -p $PORT
worker: bundle exec sidekiq -q high_priority -q normal_priority -q low_priority
redis: bundle exec redis-server
