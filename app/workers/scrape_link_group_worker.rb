class ScrapeLinkGroupWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 10

  def perform(link_group)
    Timeout::timeout(750) do 
      ActiveRecord::Base.connection_pool.with_connection do
        Scraper.make_request(link_group)
      end
    end
  rescue
    raise StandardError
  end
end