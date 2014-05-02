web: bundle exec rails server -p $PORT
sidekiq_1: bundle exec sidekiq -C config/sidekiq.yml
sidekiq_2: bundle exec sidekiq -C config/sidekiq.yml
redis: bundle exec redis-server
