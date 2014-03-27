module LinksHelper

  def embed(link)
    JSON.parse(link.embedly_json)["html"].html_safe rescue nil
  end
end
