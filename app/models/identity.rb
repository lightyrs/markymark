class Identity < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider

  validates :uid, presence: true, uniqueness: true

  class << self

    def find_with_omniauth(auth)
      find_by provider_id: Provider.find_by_name(auth['provider']).id, uid: auth['uid']
    end

    def create_with_omniauth(auth)
      create! do |identity|
        identity.uid = auth['uid']
        identity.provider_id = Provider.find_by_name(auth['provider']).id
        identity.username = auth['username'] if auth['username']
        if auth['credentials'] && auth['credentials']['token']
          identity.token = auth['credentials']['token']
        end
      end
    end
  end

  def update_token(auth)
    if auth['credentials'] && auth['credentials']['token']
      self.token = auth['credentials']['token']
    end
  end
end
