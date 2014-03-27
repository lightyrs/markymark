class HarvestLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority

  def perform(user_id, provider)
    reaper = Reaper.new(user_id: user_id, provider: provider)
    reaper.harvest_links
  end
end
