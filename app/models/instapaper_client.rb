class InstapaperClient

  include ActiveModel::Model

  def initialize(options = {})
    @client = init_client(options[:oauth_access_token], options[:oauth_secret])
  end

  def list
    @client.bookmarks_list(limit: 500)
  end

  private

  def init_client(oauth_access_token, oauth_secret)
    InstapaperFull::API.new(
      consumer_key: ENV['INSTAPAPER_CONSUMER_KEY'],
      consumer_secret: ENV['INSTAPAPER_CONSUMER_SECRET'],
      oauth_token: oauth_access_token,
      oauth_token_secret: oauth_secret
    )
  end
end
