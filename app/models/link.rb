class Link < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider

  validates :title, presence: true, uniqueness: { scope: [:description, :domain] }
  validates :url, presence: true, uniqueness: { scope: :user_id }
  validate :worthy

  before_validation :fetch_metadata, on: :create

  scope :facebook, -> { where(provider_id: Provider.facebook.id) }
  scope :twitter, -> { where(provider_id: Provider.twitter.id) }
  scope :pocket, -> { where(provider_id: Provider.pocket.id) }

  acts_as_taggable

  self.per_page = 50

  private

  def fetch_metadata
    begin
      self.url = meta_inspector_page.url rescue self.url
      self.domain = meta_inspector_page.host.gsub('www.', '') rescue domain_from_url(self.url)
      self.title = pismo_page.title rescue self.title
      self.lede = pismo_page.lede rescue nil
      self.description = meta_inspector_page.meta['description'] rescue pismo_page.description
      self.image_url = meta_inspector_page.image rescue nil
      self.content = pismo_page.body rescue nil
      assign_tags
      sleep 0.05
      self
    rescue => e
      puts "Link#fetch_metadata: #{e.class}: #{e.message}".red
      e.backtrace.each { |line| puts line.inspect.yellow }
      if e.class == SocketError
        fetch_metadata_fallback
      else
        self
      end
    end
  end

  def fetch_metadata_fallback
    begin
      self.domain = domain_from_url(self.url) rescue nil
      self.title = pismo_page.title
      self.lede = pismo_page.lede
      self.description = pismo_page.description
      self.content = pismo_page.body
      assign_tags(true)
      sleep 0.05
      self
    rescue => e
      puts "Link#fetch_metadata_fallback: #{e.class}: #{e.message}".red
      errors.add(:base, "Metadata scraping failed.")
      false
    end
  end

  def domain_from_url(url)
    Addressable::URI.parse(url).host
  end

  def meta_inspector_page
    @meta_inspector_page ||= MetaInspector.new(self.url, timeout: 5, allow_redirections: :all)
  end

  def pismo_page
    @pismo_page ||= Pismo::Document.new("#{meta_inspector_page}")
  end

  def assign_tags(fallback = false)
    begin
      tags = fallback ? "#{pismo_keywords}" : "#{pismo_keywords}, #{meta_inspector_keywords}"
      self.tag_list.add(tags, parse: true) if tags.present?
    rescue => e
      puts "Link#assign_tags: #{e.class}: #{e.message}".red
    end
  end

  def meta_inspector_keywords
    begin
      if meta_inspector_page.meta['keywords'].present?
        meta_inspector_page.meta['keywords']
      elsif meta_inspector_page.meta_tags['name'].present?
        meta_inspector_page.meta['news_keywords']
      end
    rescue => e
      nil
    end
  end

  def pismo_keywords
    pismo_page.keywords.flatten.select {|k| k.is_a? String }.join(', ') rescue nil
  end

  def worthy
    unless description.present? || lede.present? || domain.present? || image_url.present?
      errors.add(:base, 'Link is not worthy.')
    end
  end
end
