# encoding: UTF-8

class Scraper

  class << self

    def make_request(link_group)
      requests = []
      hydra = Typhoeus::Hydra.hydra
      link_group.each do |id, url|
        request = Typhoeus::Request.new("#{url}?thread_id=#{Thread.current.object_id}",
          timeout: 30,
          followlocation: true,
          connecttimeout: 7, 
          maxredirs: 2,
          ssl_verifypeer: false
        )
        requests.push({ id: id, url: url, request: request })
        hydra.queue request
      end
      hydra.run
      requests.each do |request_hash|
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            analyze_and_save(request_hash)
          rescue ActiveRecord::RecordInvalid => invalid
            invalid.record.delete
          rescue => e
            puts "#{e.class} => #{e.message.first(500)}".red_on_white
            false
          end
        end
      end
    end

    def analyze_and_save(request_hash)
      link = Link.find(request_hash[:id])
      
      pismo_page = Pismo::Document.new(
        request_hash[:request].response.try(:body), 
        url: link.url
      )
      link.url = (request_hash[:request].url || link.url) rescue nil
      link.domain = URI.parse(link.url).host.gsub('www.', '') rescue nil
      link.title = (pismo_page.title || link.title) rescue nil
      link.lede = pismo_page.lede rescue nil
      link.description = (pismo_page.description || pismo_page.lede) rescue nil
      link.content = pismo_page.body rescue nil
      link.html_content = pismo_page.html_body rescue nil

      ActiveRecord::Base.connection_pool.with_connection do
        link.tags = pismo_page.keywords.first(5).map(&:first) rescue []
      end

      link.scraped = true
      link.save!
    rescue ActiveRecord::StatementInvalid
      sleep 3
      link.save!
    end
  end
end