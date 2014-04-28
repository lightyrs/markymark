class WikipediaClient

  include ActiveModel::Model

  def initialize(options = {})
    @query = options[:query]
    raise ArgumentError if @query.ambiguous?
  end

  def fulltext
    article.to_s
  end

  def article
    @article ||= Wikipedia::article(@query)
  end
end
