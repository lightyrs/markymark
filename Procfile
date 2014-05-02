web: bundle exec rails server -p $PORT
sidekiq_1: bundle exec sidekiq -q high_priority -q normal_priority -q low_priority
sidekiq_2: bundle exec sidekiq -q high_priority -q normal_priority -q low_priority
redis: bundle exec redis-server
