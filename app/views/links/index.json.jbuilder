json.array!(@links) do |link|
  json.extract! link, :id, :title, :description, :url, :image_url, :content, :domain, :posted_at
  json.url link_url(link, format: :json)
end
