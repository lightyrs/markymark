class Link < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :title, presence: true
  validates :url, presence: true, uniqueness: { scope: :user_id }
end
