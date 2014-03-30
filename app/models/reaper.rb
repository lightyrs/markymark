class Reaper

  include ActiveModel::Model

  def initialize(options = {})
    raise ArgumentError unless @user = User.find(options[:user_id])
    raise ArgumentError unless @provider = Provider.find_by_id(options[:provider_id])
  end

  def harvest_links
    case @provider.name
    when 'facebook'
      harvest_links_from_facebook
    when 'twitter'
      harvest_links_from_twitter
    end
  end

  private

  def harvest_links_from_facebook(links = nil, options = {})
    begin
      @graph ||= GraphClient.new(@user.token(provider_id: @provider.id))
      links ||= @graph.links
      links.each_with_index do |link, index|
        if index == (links.count - 1)
          next_links = links.next_page
          harvest_links_from_facebook(next_links) if next_links.present?
        else
          create_link_from_facebook(link)
        end
      end
    rescue => e
      puts "#{e.class}: #{e.message}".red
    end
  end

  def create_link_from_facebook(link)
    begin
      @user.links.create(
        title: link['name'],
        description: link['description'],
        url: link['link'],
        image_url: link['picture'],
        posted_at: DateTime.parse(link['created_time']),
        provider_id: @provider.id
      )
    rescue => e
      puts "#{e.class}: #{e.message}".red
    end
  end

  def harvest_links_from_twitter
    client = TwitterClient.new
    tweets = client.all_tweets(@user.username(provider_id: @provider.id))
    create_links_from_twitter(tweets.select(&:urls?))
  end

  def create_links_from_twitter(tweets)
    tweets.each do |tweet|
      begin
        links = tweet.urls.map(&:expanded_url).flatten.compact
        links.each do |link|
          begin
            @user.links.create(
              url: "#{link}",
              posted_at: tweet.created_at,
              provider_id: @provider.id
            )
          rescue => e
            puts "#{e.class}: #{e.message}".red
          end
        end
      rescue => e
        puts "#{e.class}: #{e.message}".red
      end
    end
  end
end
