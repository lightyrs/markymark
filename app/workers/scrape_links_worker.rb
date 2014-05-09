class ScrapeLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :high_priority, retry: 2

  def perform(user_id, provider_id)
    Link.scrape(user_id, provider_id)
  end
end
