class Link < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :title, presence: true
  validates :url, presence: true, uniqueness: { scope: :user_id }

  before_create :fetch_metadata

  private

  def fetch_metadata
    page = MetaInspector.new(self.url)
    puts page.meta['description'].inspect
    self.domain = page.host
    self.title = page.meta['og:title'] if page.meta['og:title'].present?
    self.description = page.meta['description'] if page.meta['description'].present?
    self.image_url = page.image if page.image.present?
    sleep 0.25
  end
end
