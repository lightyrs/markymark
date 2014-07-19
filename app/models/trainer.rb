require 'classifier'
require 'madeleine'

class Trainer

  include ActiveModel::Model

  def initialize(options = {})
    @category = "#{options[:category].parameterize.underscore}"
    @sample = "#{options[:sample]}"
  end

  def classify
    m = SnapshotMadeleine.new("bayes_data") { Classifier::Bayes.new @category }
    m.system.add_category @category
    m.system.send("train_#{@category}", @sample)
    m.take_snapshot
  end
end
