class ScrapeLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 10

  def perform(user_id, provider_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Link.scrape(user_id, provider_id)
    end
  rescue
    raise StandardError
  end
end
