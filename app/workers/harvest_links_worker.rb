class HarvestLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :high_priority, unique: true, retry: 5

  def perform(user_id, provider_id = nil)
    reaper = Reaper.new(user_id: user_id, provider_id: provider_id)
    reaper.harvest_links
  rescue StandardError
    raise StandardError
  end
end
