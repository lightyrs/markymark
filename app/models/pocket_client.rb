class PocketClient

  include ActiveModel::Model

  ENDPOINT = 'https://getpocket.com'

  def initialize(oauth_access_token)
    @token = oauth_access_token
  end

  def retrieve_list
    begin
      response = get('/v3/get')
      body = JSON.parse(response.body)
      body['list']
    rescue => e
      puts "#{e.class}: #{e.message}".red
      false
    end
  end

  private

  def get(method_url)
    connection.get do |req|
      req.url method_url
      req.params['consumer_key'] = ENV['POCKET_CONSUMER_KEY']
      req.params['access_token'] = @token
    end
  end

  def connection
    @connection ||= Faraday.new(url: ENDPOINT) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end
end
