web: bundle exec rails server -p 5555
worker: bundle exec sidekiq -C ./config/sidekiq.yml
redis: leader --unless-port-in-use 6379 redis-server