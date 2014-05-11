class ScrapeLinkGroupWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 3

  def perform(link_group)
    Timeout::timeout(500) do 
      ActiveRecord::Base.connection_pool.with_connection do
        Scraper.make_request(link_group) rescue false
      end
    end
  rescue Timeout::Error
    false
  rescue => e
    puts "#{e.class}: #{e.message}".red
  end
end