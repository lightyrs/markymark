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
    when 'pocket'
      harvest_links_from_pocket
    when 'instapaper'
      harvest_links_from_instapaper
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
      url = link['link']
      title = link['name']
      posted_at = DateTime.parse(link['created_time'])
      CreateLinksWorker.perform_async(url, title, posted_at, @provider.id, @user.id)
      sleep 0.5
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
            url = "#{link}"
            posted_at = tweet.created_at
            CreateLinksWorker.perform_async(url, nil, posted_at, @provider.id, @user.id)
            sleep 0.5
          rescue => e
            puts "#{e.class}: #{e.message}".red
          end
        end
      rescue => e
        puts "#{e.class}: #{e.message}".red
      end
    end
  end

  def harvest_links_from_pocket
    client = PocketClient.new(@user.token(provider_id: @provider.id))
    links = client.retrieve_list
    create_links_from_pocket(links)
  end

  def create_links_from_pocket(links)
    links.each do |item_id, link_hash|
      begin
        url = link_hash['resolved_url'] || link_hash['given_url']
        title = link_hash['given_title'] || link_hash['resolved_title']
        posted_at = DateTime.strptime(link_hash['time_added'], '%s')
        CreateLinksWorker.perform_async(url, title, posted_at, @provider.id, @user.id)
        sleep 0.5
      rescue => e
        puts "Reaper#create_links_from_pocket: #{e.class}: #{e.message}".red
      end
    end
  end

  def harvest_links_from_instapaper
    client = InstapaperClient.new(oauth_access_token: @user.token(provider_id: @provider.id), oauth_secret: @user.secret(provider_id: @provider.id))
    links = client.list
  end
end
