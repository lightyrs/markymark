Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], scope: 'email, read_stream, user_likes, user_events, user_groups, user_interests, user_location, user_status, user_work_history'
end
