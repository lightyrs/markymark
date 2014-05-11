class HarvestLinksWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 10

  def perform(user_id, provider_id = nil)
    ActiveRecord::Base.connection_pool.with_connection do
      reaper = Reaper.new(user_id: user_id, provider_id: provider_id)
      reaper.harvest_links
    end
  rescue
    raise StandardError
  end
end
