class Link < ActiveRecord::Base

  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true, uniqueness: { scope: :user_id }
  validate :worthy

  before_create :fetch_metadata

  acts_as_taggable_on :keywords

  private

  def fetch_metadata
    begin
      page = MetaInspector.new(self.url)
      self.domain = page.host.gsub('www.', '')
      self.title = page.meta['og:title'] if page.meta['og:title'].present?
      self.description = page.meta['description'] if page.meta['description'].present?
      self.image_url = page.image if page.image.present?
      assign_keywords(page)
      sleep 0.05
    rescue StandardError
      self
    end
  end

  def assign_keywords(page)
    keywords = if page.meta['keywords'].present?
      page.meta['keywords']
    elsif page.meta_tags['name'].present?
      page.meta['news_keywords']
    end
    self.keyword_list.add(keywords, parse: true) if keywords.present?
  end

  def worthy
    unless description.present? || domain.present? || image_url.present?
      errors.add(:base, 'Link is not worthy.')
    end
  end
end
