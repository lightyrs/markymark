class CreateLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 2

  def perform(url, title, posted_at, provider_id, user_id)
    link = Link.new(
      url: url,
      title: title,
      posted_at: posted_at,
      provider_id: provider_id,
      user_id: user_id
    )
    link.save!
  end
end
