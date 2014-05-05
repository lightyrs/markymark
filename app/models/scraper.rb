class Scraper

  class << self

    def make_request(link_group)
      requests = []
      hydra = Typhoeus::Hydra.hydra
      link_group.each do |id, url|
        request = Typhoeus::Request.new(url)
        requests.push({ id: id, url: url, request: request })
        hydra.queue request
      end
      hydra.run
      Parallel.each(requests, in_threads: 8) do |request_hash|
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            puts request_hash[:id].inspect.red_on_white
            puts request_hash[:url].inspect.yellow
            link = Link.find(request_hash[:id])
            # link.html_content = request_hash[:request].response.try(:body)
            pismo_page = Pismo::Document.new(
              request_hash[:request].response.try(:body), 
              url: link.url
            )
            link.url = request_hash[:request].url rescue nil
            link.domain = Addressable::URI.parse(link.url).host.gsub('www.', '') rescue nil
            link.title = (pismo_page.title || link.title) rescue nil
            link.lede = pismo_page.lede rescue nil
            link.description = pismo_page.description rescue nil
            link.content = pismo_page.body rescue nil
            link.html_content = (pismo_page.html_body || request_hash[:request].response.try(:body)) rescue nil
            # link.tags = pismo_page.keywords.first(5).map(&:first) rescue []
            link.scraped = true
            if link.save
              puts "Successfully Saved #{link.url}".green
            else
              puts "Failed to save #{link.url}.\n\n#{link.errors.full_messages.to_sentence}".red_on_white
            end
          rescue => e
            puts "#{e.class} => #{e.message}".red
          end
        end
      end
    end
  end
end