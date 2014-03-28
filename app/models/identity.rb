class Identity < ActiveRecord::Base

  belongs_to :user

  validates :uid, presence: true, uniqueness: true

  class << self

    def find_with_omniauth(auth)
      find_by provider: auth['provider'], uid: auth['uid']
    end

    def create_with_omniauth(auth)
      create! do |identity|
        identity.uid = auth['uid']
        identity.provider = auth['provider']
        identity.username = auth['username'] if auth['username']
        if auth['credentials'] && auth['credentials']['token']
          identity.token = auth['credentials']['token']
        end
      end
    end

    def all_providers
      %w(facebook twitter)
    end
  end
end
