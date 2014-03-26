class HarvestLinksWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    user.harvest_links
  end
end
