# encoding: UTF-8

class Link < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider

  validates :url, presence: true, uniqueness: { scope: :user_id }
  validates :title, presence: true, if: Proc.new { |l| l.scraped? }
  # validate :worthy, if: Proc.new { |l| l.scraped? }

  scope :facebook, -> { where(provider_id: Provider.facebook.id) }
  scope :twitter, -> { where(provider_id: Provider.twitter.id) }
  scope :pocket, -> { where(provider_id: Provider.pocket.id) }
  scope :scraped, -> { where(scraped: true) }

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

    def scrape(user_id, provider_id)
      Link.where(user_id: user_id, provider_id: provider_id, scraped: false).
        order('posted_at DESC').pluck(:id).in_groups_of(33).each_with_index do |group, i|
          ScrapeLinkGroupWorker.perform_at(i.minutes.from_now, group)
      end
    end
  end

  def refresh
    save_metadata
  end

  def save_metadata
    if fetch_metadata
      self.scraped = true
      save
    end
  end

  def is_image?
    url.match(/\.(png|jpg|gif)$/).present?
  end

  def sample
    if content && content.length > description.length
      content
    elsif description && description.length > 10
      description
    elsif title && title.length > 10
      title
    elsif tags.any?
      tags.join(", ")
    else
      domain
    end
  end

  private

  def queue_metadata_worker
    UpdateLinksWorker.perform_async(self.id)
  end

  def fetch_metadata
    begin
      meta_inspector_page = MetaInspector.new(self.url, timeout: 30, allow_redirections: :all, warn_level: :warn)
      pismo_page = Pismo::Document.new(self.url)

      self.url = (meta_inspector_page.meta['og:url'] || meta_inspector_page.url) rescue self.url
      self.domain = meta_inspector_page.host.gsub('www.', '') rescue Addressable::URI.parse(self.url).host.gsub('www.', '')
      self.title = (pismo_page.title || meta_inspector_page.title) rescue self.title
      self.lede = pismo_page.lede rescue self.lede
      self.description = (meta_inspector_page.description || pismo_page.description) rescue self.description
      self.image_url = meta_inspector_page.image rescue self.image_url
      self.content = pismo_page.body rescue self.content
      self.html_content = pismo_page.html_body rescue self.html_content
      self.content_links = meta_inspector_page.links rescue self.content_links
      self.tags << pismo_page.keywords.first(5).map(&:first) rescue self.tags
      true
    rescue => e
      puts "Link#fetch_metadata: #{e.class}: #{e.message}".red_on_white
      false
    end
  end

  def worthy
    unless domain.present? || description.present? || lede.present? || image_url.present?
      errors.add(:base, 'Link is not worthy.')
    end
  end
end
