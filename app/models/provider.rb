class Provider < ActiveRecord::Base

  has_many :identities
  has_many :links

  validates :name, presence: true, uniqueness: true

  class << self

    def seed
      Provider.facebook
      Provider.twitter
      Provider.pocket
      Provider.instapaper
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

    def pocket
      find_or_create_by!(name: 'pocket') do |provider|
        provider.domain = 'getpocket.com'
        provider.description = 'Save For Later. Put articles, videos or pretty much anything into Pocket. Save directly from your browser or from apps like Twitter, Flipboard, Pulse and Zite.'
      end
    end

    def instapaper
      find_or_create_by!(name: 'instapaper') do |provider|
        provider.domain = 'instapaper.com'
        provider.description = 'A simple tool for saving web pages to read later on your iPhone, iPad, Android, computer, or Kindle.'
      end
    end
  end
end
