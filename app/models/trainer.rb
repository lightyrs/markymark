class Trainer

  include ActiveModel::Model

  def initialize(options = {})
    @bayes = OmniCat::Classifiers::Bayes.new
  end

  def usa_today_sample
    @usa_today_client ||= UsaTodayClient.new
    @sample ||= @usa_today_client.sample
    puts @sample.inspect.red
    @sample
  end

  class << self

    def pismo_page(url)
      Pismo::Document.new(url)
    end
  end
end
