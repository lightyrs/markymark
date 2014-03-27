class Reaper

  include ActiveModel::Model

  def initialize(args = {})
    @provider = args[:provider]
    raise ArgumentError unless @user = User.find(args[:user_id])
    raise ArgumentError unless Identity.all_providers.include? @provider
  end

  def harvest_links
    case @provider
    when 'facebook'
      harvest_links_from_facebook
    when 'twitter'
      harvest_links_from_twitter
    end
  end

  private

  def harvest_links_from_facebook(links = nil)
    graph = GraphClient.new(@user.facebook_token)
    links ||= graph.links
    links.each_with_index do |link, index|
      if index == (links.count - 1)
        next_links = links.next_page
        harvest_links_from_facebook(next_links) if next_links.present?
      else
        create_links_from_facebook(links)
      end
    end
  end

  def create_links_from_facebook(links)
    links.each do |link|
      begin
        @user.links.create(
          title: link['name'],
          description: link['description'],
          url: link['link'],
          image_url: link['picture'],
          posted_at: DateTime.parse(link['created_time'])
        )
      rescue StandardError => e
        puts "#{e.class}: #{e.message}"
      end
    end
  end
end