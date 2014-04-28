class Classification < ActiveRecord::Base

  class << self

    def seed
      text.each do |name|
        Classification.find_or_create_by!(name: name, content_type: 'text')
      end
      image.each do |name|
        Classification.find_or_create_by!(name: name, content_type: 'image')
      end
      video.each do |name|
        Classification.find_or_create_by!(name: name, content_type: 'video')
      end
      audio.each do |name|
        Classification.find_or_create_by!(name: name, content_type: 'audio')
      end
      multimedia.each do |name|
        Classification.find_or_create_by!(name: name, content_type: 'multimedia')
      end
    end

    def text
      ['News', 'Interview', 'List', 'Review', 'Tutorial', 'Comparison', 'Case Study', 'Rant', 'Story', 'Prediction', 'Press Release', 'Analysis', 'Live Blog', 'Q&A', 'Contest', 'Transcription', 'Summary', 'Advice', 'Guide', 'Round Up', 'Op-Ed', 'Comment', 'Historical', 'Status', 'Code', 'Technical', 'E-book']
    end

    def image
      ['Infographic', 'Slideshow', 'News']
    end

    def video
      ['Webisode', 'Vlog', 'Music Video', 'Movie Trailer', 'TV Show', 'Movie', 'Commercial', 'News', 'Historical', 'Podcast', 'Interview', 'Tutorial', 'Review', 'Press Release', 'Live Stream']
    end

    def audio
      ['Song', 'Interview', 'News', 'Historical', 'Podcast', 'Talk Radio']
    end

    def multimedia
      ['Presentation']
    end
  end
end
