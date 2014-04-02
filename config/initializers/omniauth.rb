Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], scope: 'email, read_stream, user_likes, user_events, user_groups, user_interests, user_location, user_status, user_work_history'
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  provider :pocket, ENV['POCKET_CONSUMER_KEY']
  provider :instapaper, ENV['INSTAPAPER_CONSUMER_KEY'], ENV['INSTAPAPER_CONSUMER_SECRET']
end
