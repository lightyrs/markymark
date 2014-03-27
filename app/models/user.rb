class User < ActiveRecord::Base

  has_many :links
  has_many :identities, dependent: :destroy

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
          HarvestLinksWorker.perform_async(user.id, identity.provider)
        end
      end
    end
  end

  def disconnected_providers
    Identity.all_providers - connected_providers
  end

  def connected_providers
    identities.pluck(:provider)
  end

  def connected_facebook?
    identities.where(provider: 'facebook').any?
  end

  def connected_twitter?
    identities.where(provider: 'twitter').any?
  end
end
