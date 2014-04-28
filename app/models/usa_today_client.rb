class UsaTodayClient

  include ActiveModel::Model

  ENDPOINT = 'http://api.usatoday.com'

  def initialize(options = {})
    @tag = options[:tag]
  end

  def sample
    sample = {}
    usa_today_news_categories.each do |section, category|
      begin
        @section = section
        if a = articles
          category.each do |cat|
            sample["#{cat}"] = a
          end
        else
          b = articles
          category.each do |cat|
            sample["#{cat}"] = b
          end
        end
        sleep 4
      rescue => e
        puts "#{e.class}: #{e.message}".red
      end
    end
    sample
  end

  def articles
    begin
      response = get('/open/articles')
      body = JSON.parse(response.body)
      body['stories'].map { |story| story['link'] }
    rescue => e
      puts "#{e.class}: #{e.message}".red
      false
    end
  end

  private

  def get(method_url)
    connection.get do |req|
      req.url method_url
      req.params['api_key'] = ENV['USA_TODAY_ARTICLES_KEY']
      req.params['section'] = @section if @section.present?
      req.params['tag'] = @tag if @tag.present?
      req.params['most'] = 'commented'
      req.params['encoding'] = 'json'
      req.params['count'] = '100'
    end
  end

  def connection
    @connection ||= Faraday.new(url: ENDPOINT) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def usa_today_news_categories
    {
      money: %w(money finance),
      sports: %w(sports),
      life: %w(life),
      tech: %w(technology),
      weather: %w(weather),
      offbeat: %w(offbeat novel),
      washington: %w(politics),
      religion: %w(religion),
      nfl: %w(sports football nfl),
      mlb: %w(sports baseball mlb),
      nba: %w(sports basketball nba),
      nhl: %w(sports hockey nhl),
      collegefootball: %w(sports football college),
      collegebasketball: %w(sports basketball college),
      motorsports: %w(sports motorsports),
      golf: %w(sports golf),
      soccer: %w(sports soccer),
      horseracing: %w(sports horseracing),
      books: %w(books),
      people: %w(people),
      music: %w(music entertainment),
      reviews: %w(reviews opinion)
    }
  end

  def usa_today_blog_categories
    {
      religion: %w(religion),
      onpolitics: %w(politics),
      thehuddle: %w(sports),
      entertainment: %w(entertainment),
      sciencefair: %w(science),
      technologylive: %w(technology)
    }
  end
end
