class ScrapeLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, unique: true, retry: 5

  def perform(user_id, provider_id)
    Link.scrape(user_id, provider_id)
  rescue StandardError
    raise StandardError
  end
end
