class Identity < ActiveRecord::Base

  belongs_to :user

  validates :uid, presence: true, uniqueness: true

  class << self

    def find_with_omniauth(auth)
      find_by provider: auth['provider'], uid: auth['uid']
    end

    def create_with_omniauth(auth)
      create(uid: auth['uid'], provider: auth['provider'])
    end

    def all_providers
      %w(facebook twitter)
    end
  end
end
