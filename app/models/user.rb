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
      end
      u.tap do |user|
        if user.persisted?
          identity.update_attributes(user_id: user.id)
          HarvestLinksWorker.perform_async(user.id, identity.provider_id)
        end
      end
    end
  end

  def token(options = {})
    raise ArgumentError unless identity = identities.where(provider_id: options[:provider_id]).first
    identity.token
  end

  def username(options = {})
    raise ArgumentError unless identity = identities.where(provider_id: options[:provider_id]).first
    identity.username
  end

  def disconnected_providers
    Provider.all - connected_providers
  end

  def connected_providers
    identities.map(&:provider)
  end

  def connected_facebook?
    identities.where(provider_id: Provider.find_by_name('facebook')).any?
  end

  def connected_twitter?
    identities.where(provider_id: Provider.find_by_name('twitter')).any?
  end
end
