Sidekiq.configure_client do |config|
  config.redis = { size: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { size: 5 }
  config.poll_interval = 3
  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler, storage: :redis
  end
end