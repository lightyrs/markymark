class GraphClient

  include ActiveModel::Model

  def initialize(oauth_access_token)
    @client = Koala::Facebook::API.new(oauth_access_token)
  end

  def me
    @client.get_object('me')
  end

  def feed
    @client.get_connections('me', 'feed')
  end

  def links
    @client.get_connections('me', 'links')
  end
end
