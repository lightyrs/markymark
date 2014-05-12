# encoding: UTF-8

class Scraper

  class << self

    def make_request(link_group)
      requests = []
      hydra = Typhoeus::Hydra.hydra
      link_group.each do |id, url|
        request = Typhoeus::Request.new("#{url}?thread_id=#{Thread.current.object_id}",
          timeout: 60,
          followlocation: true,
          connecttimeout: 30, 
          maxredirs: 4,
          ssl_verifypeer: false
        )
        requests.push({ id: id, url: url, request: request })
        hydra.queue request
      end
      hydra.run
      begin
        requests.each do |request_hash|
          ActiveRecord::Base.connection_pool.with_connection do
            begin
              analyze_and_save(request_hash)
            rescue ActiveRecord::RecordInvalid => invalid
              puts invalid.record.inspect.green
            rescue => e
              puts "#{e.class} => #{e.message.first(500)}".red_on_white
            end
          end
        end
      rescue
        raise StandardError
      end
    end

    def analyze_and_save(request_hash)
      return false unless link = Link.find_by(id: request_hash[:id])      
      
      pismo_page = Pismo::Document.new(
        request_hash[:request].response.try(:body), 
        url: link.url
      )

      unless pismo_page && pismo_page.title.present?
        pismo_page = Pismo::Document.new(link.url)
      end

      link.url = (request_hash[:request].url || link.url) rescue link.url
      link.domain = URI.parse(link.url).host.gsub('www.', '') rescue nil
      link.title = (pismo_page.title || link.title) rescue link.title
      link.lede = pismo_page.lede rescue nil
      link.description = (pismo_page.description || pismo_page.lede) rescue nil
      link.content = pismo_page.body rescue nil
      link.html_content = pismo_page.html_body rescue nil
      link.tags = pismo_page.keywords.first(5).map(&:first) rescue []
      link.scraped = true
      link.save!
    rescue ActiveRecord::StatementInvalid
      sleep 3
      link.save!
    end
  end
end