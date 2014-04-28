class Trainer

  include ActiveModel::Model

  def initialize(options = {})
    @redis = Redis.new
    if @redis.get('bayes') && bayes_hash = JSON.parse(@redis.get('bayes'))
      @bayes = OmniCat::Classifiers::Bayes.new(bayes_hash)
    else
      @bayes = OmniCat::Classifiers::Bayes.new
    end
  end

  def train
    @redis.set 'bayes', usa_today_sample.to_json
  end

  def usa_today_sample
    @usa_today_client ||= UsaTodayClient.new
    @sample ||= @usa_today_client.sample
    @sample.each do |category, links|
      @bayes.add_category(category)
      begin
        links.each do |link|
          begin
            page = Trainer.pismo_page(link)
            @bayes.train_batch(category, [page.title, (page.lede || page.description), page.body])
          rescue => e
            puts "#{e.class}: #{e.message}".red
          end
        end
      rescue => e
        puts "#{e.class}: #{e.message}".red
      end
    end
    @bayes.to_hash
  end

  class << self

    def pismo_page(url)
      Pismo::Document.new(url)
    end
  end
end
