class ScrapeLinkGroupWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, unique: true, retry: 3

  def perform(link_group)
    Timeout::timeout(750) do
      Scraper.make_request(link_group)
    end
  rescue StandardError
    raise StandardError
  end
end