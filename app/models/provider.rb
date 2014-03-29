class Provider < ActiveRecord::Base

  has_many :identities
  has_many :links

  validates :name, presence: true, uniqueness: true

  class << self

    def seed
      Provider.facebook
      Provider.twitter
    end

    def facebook
      find_or_create_by!(name: 'facebook') do |provider|
        provider.domain = 'facebook.com'
        provider.description = 'Facebook is a social utility that connects people with friends and others who work, study and live around them.'
      end
    end

    def twitter
      find_or_create_by!(name: 'twitter') do |provider|
        provider.domain = 'twitter.com'
        provider.description = 'Twitter is an online social networking and microblogging service that enables users to send and read short 140-character text messages, called "tweets".'
      end
    end
  end
end
