class UpdateLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 2

  def perform(link_id)
    Link.refresh(link_id)
  end
end
