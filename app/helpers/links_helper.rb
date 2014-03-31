module LinksHelper

  include ActsAsTaggableOn::TagsHelper

  def embed(link)
    JSON.parse(link.embedly_json)["html"].html_safe rescue nil
  end
end
