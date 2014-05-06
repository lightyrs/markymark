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
            analyze_and_save(request_hash)
          rescue ActiveRecord::RecordInvalid => invalid
            invalid.record.delete
          rescue => e
            puts "#{e.class} => #{e.message.first(500)}".red_on_white
          end
        end
      end
    end

    def analyze_and_save(request_hash)
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
      link.save!
    end
  end
end