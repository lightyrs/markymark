class User < ActiveRecord::Base

  has_many :links

  validates_presence_of :uid
  validates_presence_of :name
  validates_presence_of :email

  class << self

    def create_with_omniauth(auth)
      u = create! do |user|
        user.provider = auth['provider']
        user.uid = auth['uid']
        if auth['info']
           user.name = auth['info']['name'] || ""
           user.email = auth['info']['email'] || ""
        end
        if auth['credentials'] && auth['credentials']['token']
          user.facebook_token = auth['credentials']['token']
        end
      end
      u.tap do |user|
        HarvestLinksWorker.perform_async(user.id) if user.persisted?
      end
    end
  end

  def harvest_links(links = nil)
    graph = GraphClient.new(facebook_token)
    links ||= graph.links
    links.each_with_index do |link, index|
      if index == (links.count - 1)
        next_links = links.next_page
        harvest_links(next_links) if next_links.present?
      else
        create_links(links)
      end
    end
  end

  def create_links(links)
    begin
      links.each do |link|
        self.links.create(
          title: link['name'],
          description: link['description'],
          url: link['link'],
          image_url: link['picture'],
          posted_at: DateTime.parse(link['created_time'])
        )
      end
    rescue => e
      puts "#{e.class}: #{e.message}"
    end
  end
end
