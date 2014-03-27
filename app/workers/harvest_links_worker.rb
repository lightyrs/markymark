class HarvestLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority

  def perform(user_id)
    user = User.find(user_id)
    user.harvest_links
  end
end
