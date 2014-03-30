class Link < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider

  validates :title, presence: true, uniqueness: { scope: [:description, :domain] }
  validates :url, presence: true, uniqueness: { scope: :user_id }
  validate :worthy

  before_validation :fetch_metadata, on: :create

  serialize :embedly_json, JSON

  scope :facebook, -> { where(provider_id: Provider.facebook.id) }
  scope :twitter, -> { where(provider_id: Provider.twitter.id) }

  acts_as_taggable_on :keywords

  self.per_page = 50

  def embeddable?
    embeddable_url.present?
  end

  def embeddable_url
    url.scan(EmbedlyClient.regexp).flatten.first
  end

  private

  def fetch_metadata
    begin
      self.url = meta_inspector_page.url
      self.domain = meta_inspector_page.host.gsub('www.', '')
      self.title = pismo_page.title
      self.lede = pismo_page.lede
      self.description = meta_inspector_page.meta['description']
      self.image_url = meta_inspector_page.image
      self.content = pismo_page.body
      assign_keywords
      # assign_embedly_json(self.url) if self.url && self.embeddable?
      sleep 0.05
      self
    rescue StandardError => e
      puts "#{e.class}: #{e.message}".red
      self
    end
  end

  def meta_inspector_page
    @meta_inspector_page ||= MetaInspector.new(self.url, timeout: 6, allow_redirections: :all)
  end

  def pismo_page
    @pismo_page ||= Pismo::Document.new("#{meta_inspector_page}")
  end

  def assign_keywords
    meta_inspector_keywords = if meta_inspector_page.meta['keywords'].present?
      meta_inspector_page.meta['keywords']
    elsif meta_inspector_page.meta_tags['name'].present?
      meta_inspector_page.meta['news_keywords']
    end
    pismo_keywords = pismo_page.keywords.flatten.select {|k| k.is_a? String }.join(', ')
    keywords = "#{meta_inspector_keywords}, #{pismo_keywords}"
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
