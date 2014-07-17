require 'classifier'
require 'madeleine'

class Trainer

  include ActiveModel::Model

  class << self

    def pismo_page(url)
      Pismo::Document.new(url)
    end

    def classify(options = {})
      category = options[:category].parameterize.underscore
      
      m = SnapshotMadeleine.new("bayes_data") do
        Classifier::Bayes.new category
      end
      m.system.send("train_#{category}", "#{options[:sample]}")
      m.take_snapshot
    end
  end

  def train
    redis.set 'bayes', usa_today_sample.to_json
  end

  def usa_today_sample
    @sample ||= usa_today_client.sample
    @sample.each do |category, links|
      bayes.add_category(category)
      begin
        links.each do |link|
          begin
            page = Trainer.pismo_page(link)
            bayes.train_batch(category, [page.title, (page.lede || page.description), page.body])
          rescue => e
            puts "#{e.class}: #{e.message}".red
          end
        end
      rescue => e
        puts "#{e.class}: #{e.message}".red
      end
    end
    bayes.to_hash
  end

  private

  def bayes
    @bayes ||= OmniCat::Classifiers::Bayes.new bayes_data
  end

  def bayes_data
    JSON.parse redis.get 'bayes' rescue nil
  end

  def usa_today_client
    @usa_today_client ||= UsaTodayClient.new
  end

  def redis
    @redis ||= Redis.new
  end
end
