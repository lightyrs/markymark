class Link < ActiveRecord::Base

  serialize :content_links, Array

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

  class << self

    def refresh_all
      Link.find_each(&:refresh)
    end
  end

  def refresh
    fetch_metadata
    save!
  end

  private

  def fetch_metadata
    begin
      self.url = meta_inspector_page.url rescue self.url
      self.domain = meta_inspector_page.host.gsub('www.', '')
      self.title = pismo_page.title
      self.lede = pismo_page.lede
      self.description = meta_inspector_page.meta['description']
      self.image_url = meta_inspector_page.image
      # self.content = pismo_page.body
      # self.html_content = pismo_page.html_body
      # self.content_links = meta_inspector_page.links
      assign_tags
      self
    rescue => e
      puts "Link#fetch_metadata: #{e.class}: #{e.message}".red
      if e.class == SocketError
        fetch_metadata_fallback
      else
        false
      end
    end
  end

  def fetch_metadata_fallback
    begin
      self.domain = Addressable::URI.parse(self.url).host.gsub('www.', '') rescue nil
      self.title = pismo_page.title
      self.lede = pismo_page.lede
      self.description = pismo_page.description
      self.content = pismo_page.body
      assign_tags
      self
    rescue => e
      puts "Link#fetch_metadata_fallback: #{e.class}: #{e.message}".red
      false
    end
  end

  def assign_tags
    begin
      self.tag_list.add("#{pismo_keywords}", parse: true) if tags.present?
    rescue => e
      puts "Link#assign_tags: #{e.class}: #{e.message}".red
    end
  end

  def meta_inspector_keywords
    if meta_inspector_page.meta['keywords'].present?
      meta_inspector_page.meta['keywords']
    elsif meta_inspector_page.meta_tags['name'].present?
      meta_inspector_page.meta['news_keywords']
    end
  end

  def pismo_keywords
    pismo_page.keywords.sort_by(&:last).reverse.first(5).flatten.select {|k| k.is_a?(String) && k.length < 100 }.join(', ')
  end

  def worthy
    unless description.present? || lede.present? || domain.present? || image_url.present?
      errors.add(:base, 'Link is not worthy.')
    end
  end

  def meta_inspector_page
    @meta_inspector_page ||= MetaInspector.new(self.url, timeout: 4, allow_redirections: :all)
  end

  def pismo_page
    @pismo_page ||= Pismo::Document.new(self.url)
  end
end
