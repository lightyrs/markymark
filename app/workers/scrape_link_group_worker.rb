class ScrapeLinkGroupWorker

  include Sidekiq::Worker

  sidekiq_options queue: :normal_priority, retry: 2

  def perform(link_group)
    Scraper.make_request(link_group) rescue false
  end
end