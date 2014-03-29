class TwitterClient

  include ActiveModel::Model

  MAX_ATTEMPTS = 3

  def initialize
    @client = init_client
  end

  def all_tweets(user)
    collect_with_max_id do |max_id|
      options = { count: 200, include_rts: true }
      options[:max_id] = max_id unless max_id.nil?
      @client.user_timeline(user, options)
    end
  end

  private

  def collect_with_max_id(collection=[], max_id=nil, &block)
    @num_attempts ||= 0
    begin
      @num_attempts += 1
      response = yield(max_id)
      collection += response
      if response.empty?
        collection.flatten
      else
        sleep 1
        collect_with_max_id(collection, response.last.id - 1, &block)
      end
    rescue Twitter::Error::TooManyRequests => error
      if @num_attempts <= MAX_ATTEMPTS
        sleep error.rate_limit.reset_in
        retry
      else
        raise
      end
    end
  end

  def init_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end
end
