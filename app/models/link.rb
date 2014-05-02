class Link < ActiveRecord::Base

  serialize :content_links, Array

  belongs_to :user
  belongs_to :provider

  validates :url, presence: true, uniqueness: { scope: :user_id }
  validates :title, presence: true, uniqueness: { scope: :domain }
  validate :worthy

  scope :facebook, -> { where(provider_id: Provider.facebook.id) }
  scope :twitter, -> { where(provider_id: Provider.twitter.id) }
  scope :pocket, -> { where(provider_id: Provider.pocket.id) }

  attr_taggable :tags

  self.per_page = 50

  class << self

    def process(url, title, posted_at, provider_id, user_id)
      link = Link.new(
        url: url,
        title: title,
        posted_at: posted_at,
        provider_id: provider_id,
        user_id: user_id
      )
      link.save_metadata
    rescue => e
      puts "Link.process: #{e.class}: #{e.message}".white_on_black
      false
    end

    def refresh(link_id)
      Link.find(link_id).save_metadata
    end
  end

  def save_metadata
    if fetch_metadata
      self.scraped = true
      save
    end
  end

  private

  def queue_metadata_worker
    UpdateLinksWorker.perform_async(self.id)
  end

  def fetch_metadata
    begin
      self.url = (meta_inspector_page.meta['og:url'] || meta_inspector_page.url) rescue self.url
      self.domain = meta_inspector_page.host.gsub('www.', '') rescue Addressable::URI.parse(self.url).host.gsub('www.', '')
      self.title = (pismo_page.title || meta_inspector_page.title) rescue self.title
      self.lede = pismo_page.lede rescue nil
      self.description = meta_inspector_page.description rescue pismo_page.description
      self.image_url = meta_inspector_page.image rescue nil
      self.content = pismo_page.body rescue nil
      self.html_content = pismo_page.html_body rescue nil
      self.content_links = meta_inspector_page.links rescue []
      self.tags = pismo_keywords rescue []
      true
    rescue => e
      puts "Link#fetch_metadata: #{e.class}: #{e.message}".red_on_white
      false
    end
  end

  def pismo_keywords
    pismo_page.keywords.sort_by(&:last).reverse.first(5).flatten.select {|k| k.is_a?(String) && k.length < 100 }
  end

  def worthy
    unless domain.present? || description.present? || lede.present? || image_url.present?
      errors.add(:base, 'Link is not worthy.')
    end
  end

  def meta_inspector_page
    @meta_inspector_page ||= MetaInspector.new(self.url, timeout: 3, allow_redirections: :all, warn_level: :warn)
  end

  def pismo_page
    @pismo_page ||= Pismo::Document.new(self.url)
  end
end
