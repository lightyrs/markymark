Sidekiq.configure_client do |config|
  config.redis = { size: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { size: 5 }
  config.poll_interval = 3
  ActiveRecord::Base.connection.disconnect!
  ActiveRecord::Base.configurations[Rails.env]['timeout'] = 300000
  ActiveRecord::Base.establish_connection
end