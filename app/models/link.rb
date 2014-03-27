class Link < ActiveRecord::Base

  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true, uniqueness: { scope: :user_id }
  validate :worthy

  before_create :fetch_metadata

  serialize :embedly_json, JSON

  acts_as_taggable_on :keywords

  def embeddable?
    embeddable_url.present?
  end

  def embeddable_url
    url.scan(EmbedlyClient.regexp).flatten.first
  end

  private

  def fetch_metadata
    begin
      page = MetaInspector.new(self.url)
      self.domain = page.host.gsub('www.', '')
      self.title = page.meta['og:title'] if page.meta['og:title'].present?
      self.description = page.meta['description'] if page.meta['description'].present?
      self.image_url = page.image if page.image.present?
      assign_keywords(page)
      assign_embedly_json(self.url) if self.url && self.url.embeddable?
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

  def assign_embedly_json(url)
    @embedly_client ||= EmbedlyClient.new
    self.embedly_json = @embedly_client.embed(url)
  end

  def worthy
    unless description.present? || domain.present? || image_url.present?
      errors.add(:base, 'Link is not worthy.')
    end
  end
end
