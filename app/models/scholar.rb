require 'treat'
include Treat::Core::DSL

class Scholar

  include ActiveModel::Model

  attr_reader :treat_doc

  def initialize(options = {})
    @treat_doc = section options[:document]
    @treat_doc.apply :chunk, :segment, :tokenize, :category, :name_tag
  end

  def words_by_frequency
    word_hash = {}
		downcase_words = @treat_doc.words.map {|word| word.to_s.downcase}.uniq
		downcase_words.each{|word| (word_hash[word] = @treat_doc.frequency_of word) unless word.category == 'determiner' || word.category == 'preposition'}
		word_popularity = word_hash.sort_by {|word,count|count}.reverse
  end
end
