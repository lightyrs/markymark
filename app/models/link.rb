class Link < ActiveRecord::Base

  serialize :content_links, Array

  belongs_to :user
  belongs_to :provider

  validates :url, presence: true, uniqueness: { scope: :user_id }
  validates :title, presence: true, uniqueness: { scope: [:description, :domain] }, if: Proc.new { |link| link.scraped? }
  validate :worthy, if: Proc.new { |link| link.scraped? }

  after_commit :queue_metadata_worker, on: :create

  scope :facebook, -> { where(provider_id: Provider.facebook.id) }
  scope :twitter, -> { where(provider_id: Provider.twitter.id) }
  scope :pocket, -> { where(provider_id: Provider.pocket.id) }

  acts_as_taggable

  self.per_page = 50

  class << self

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
      self.url = meta_inspector_page.url rescue self.url
      self.domain = meta_inspector_page.host.gsub('www.', '')
      self.title = pismo_page.title
      self.lede = pismo_page.lede
      self.description = meta_inspector_page.meta['description']
      self.image_url = meta_inspector_page.image
      self.content = pismo_page.body
      self.html_content = pismo_page.html_body
      self.content_links = meta_inspector_page.links
      assign_tags
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
    rescue => e
      puts "Link#fetch_metadata_fallback: #{e.class}: #{e.message}".red
      false
    end
  end

  def assign_tags
    begin
      self.tag_list.add("#{pismo_keywords}", parse: true)
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
    unless domain.present? || description.present? || lede.present? || image_url.present?
      errors.add(:base, 'Link is not worthy.')
    end
  end

  def meta_inspector_page
    @meta_inspector_page ||= MetaInspector.new(self.url, timeout: 3, allow_redirections: :all)
  end

  def pismo_page
    @pismo_page ||= Pismo::Document.new(self.url)
  end
end
