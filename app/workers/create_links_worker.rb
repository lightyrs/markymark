class CreateLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 2, throttle: { threshold: 100, period: 1.minute }

  def perform(url, title, posted_at, provider_id, user_id)
    Link.process(url, title, posted_at, provider_id, user_id)
  end
end
