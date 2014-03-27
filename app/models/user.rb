class User < ActiveRecord::Base

  has_many :links
  has_many :identities

  validates_presence_of :name

  class << self

    def find_or_create_with_omniauth(identity, auth)
      user = User.find_by_email(auth['info']['email'])
      user.nil? ? create_with_omniauth(identity, auth) : user
    end

    def create_with_omniauth(identity, auth)
      u = create! do |user|
        if auth['info']
           user.name = auth['info']['name'] || ""
           user.email = auth['info']['email'] || ""
        end
        if auth['credentials'] && auth['credentials']['token']
          user.facebook_token = auth['credentials']['token']
        end
      end
      u.tap do |user|
        if user.persisted?
          identity.update_attributes(user_id: user.id)
          HarvestLinksWorker.perform_async(user.id) if identity.provider == 'facebook'
        end
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
    links.each do |link|
      begin
        self.links.create(
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
