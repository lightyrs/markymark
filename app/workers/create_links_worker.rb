class CreateLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 3

  def perform(url, title, posted_at, provider_id, user_id)
    raise ArgumentError unless user = User.find_by_id(user_id)
    user.links.create(
      url: url,
      title: title,
      posted_at: posted_at,
      provider_id: provider_id,
      user_id: user_id
    )
  end
end
