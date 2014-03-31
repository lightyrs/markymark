class Link < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider

  validates :title, presence: true, uniqueness: { scope: [:description, :domain] }
  validates :url, presence: true, uniqueness: { scope: :user_id }
  validate :worthy

  before_validation :fetch_metadata, on: :create

  scope :facebook, -> { where(provider_id: Provider.facebook.id) }
  scope :twitter, -> { where(provider_id: Provider.twitter.id) }

  acts_as_taggable

  self.per_page = 50

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
      assign_tags
      sleep 0.05
      self
    rescue => e
      puts "#{e.class}: #{e.message}".red
      self
    end
  end

  def meta_inspector_page
    @meta_inspector_page ||= MetaInspector.new(self.url, timeout: 5, allow_redirections: :all)
  end

  def pismo_page
    @pismo_page ||= Pismo::Document.new("#{meta_inspector_page}")
  end

  def assign_tags
    begin
      meta_inspector_keywords = if meta_inspector_page.meta['keywords'].present?
        meta_inspector_page.meta['keywords']
      elsif meta_inspector_page.meta_tags['name'].present?
        meta_inspector_page.meta['news_keywords']
      end
      pismo_keywords = pismo_page.keywords.flatten.select {|k| k.is_a? String }.join(', ')
      tags = "#{meta_inspector_keywords}, #{pismo_keywords}"
      self.tag_list.add(tags, parse: true) if tags.present?
    rescue => e
      puts "#{e.class}: #{e.message}".red
    end
  end

  def worthy
    unless description.present? || domain.present? || image_url.present?
      errors.add(:base, 'Link is not worthy.')
    end
  end
end
