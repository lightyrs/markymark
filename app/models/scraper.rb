# encoding: UTF-8

class Scraper

  class << self

    def make_request(link_group)
      requests = []
      Thread.current[:hydra] ||= Typhoeus::Hydra.hydra
      hydra = Thread.current[:hydra]
      link_group = Link.find(link_group.flatten)
      link_group.each do |link|
        begin
          request = Typhoeus::Request.new("#{link.url}?thread_id=#{Thread.current.object_id}",
            timeout: 45,
            followlocation: true,
            connecttimeout: 20,
            maxredirs: 6,
            ssl_verifypeer: false,
            headers: { Accept: 'text/html' }
          )
          requests.push({ id: link.id, url: link.url, request: request })
          hydra.queue request
        rescue => e
          puts "#{e.class} => #{e.message.first(200)}".red_on_white
        end
      end
      hydra.run
      begin
        requests.each do |request_hash|
          begin
            analyze_and_save(request_hash)
          rescue ActiveRecord::RecordInvalid => invalid
            puts invalid.record.errors.full_messages.inspect.white_on_red
          rescue => e
            puts "#{e.class} => #{e.message.first(200)}".red_on_white
          end
        end
      rescue => e
        puts "#{e.class} => #{e.message.first(200)}".red_on_white
        raise StandardError
      end
    end

    def analyze_and_save(request_hash)
      return false unless response = request_hash[:request].response.try(:body)
      return false unless link = Link.find(request_hash[:id])
      return false if link.is_image?

      pismo_page = Pismo::Document.new(response, url: link.url) rescue nil

      unless pismo_page && pismo_page.title.present?
        pismo_page = Pismo::Document.new(link.url)
      end

      link.url = (request_hash[:request].response.try(:effective_url) || link.url) rescue link.url
      link.domain = URI.parse(link.url).host.gsub('www.', '') rescue ''
      link.title = (pismo_page.title || link.title) rescue link.title
      link.lede = pismo_page.lede rescue ''
      link.description = (pismo_page.description || pismo_page.lede) rescue ''
      link.content = pismo_page.body rescue ''
      link.html_content = (pismo_page.html_body || response) rescue response
      link.tags = pismo_page.keywords.first(5).
        map { |k| k.first.squish! }.compact.
        select { |k| k.length > 1 } rescue []
      link.scraped = true
      link.save!
    rescue ActiveRecord::StatementInvalid
      link.save!
    end
  end
end