class User < ActiveRecord::Base
  validates_presence_of :name

  def self.create_with_omniauth(auth)
    create! do |user|
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
  end

end
