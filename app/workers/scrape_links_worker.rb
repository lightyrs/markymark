class ScrapeLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :high_priority, retry: 2

  def perform(user_id, provider_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Link.scrape(user_id, provider_id) rescue false
    end
  end
end
