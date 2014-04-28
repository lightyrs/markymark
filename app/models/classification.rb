class Classification < ActiveRecord::Base

  validate :name, presence: true, uniqueness: { scope: :content_type }

  class << self

    def seed
      content_types.each do |content_type, names|
        names.each do |name|
          Classification.find_or_create_by!(name: name, content_type: content_type)
        end
      end
    end

    def content_types
      {
        text: text,
        image: image,
        video: video,
        audio: audio,
        multimedia: multimedia
      }
    end

    def text
      ['News', 'Interview', 'List', 'Review', 'Tutorial', 'Comparison', 'Case Study', 'Rant', 'Story', 'Prediction', 'Press Release', 'Analysis', 'Live Blog', 'Q&A', 'Contest', 'Transcription', 'Summary', 'Advice', 'Guide', 'Round Up', 'Op-Ed', 'Comment', 'Historical', 'Status', 'Code', 'Technical', 'E-book', 'Advertisement']
    end

    def image
      ['Infographic', 'Slideshow', 'News', 'Advertisement']
    end

    def video
      ['Webisode', 'Vlog', 'Music Video', 'Movie Trailer', 'TV Show', 'Movie', 'Commercial', 'News', 'Historical', 'Podcast', 'Interview', 'Tutorial', 'Review', 'Press Release', 'Live Stream', 'Advertisement']
    end

    def audio
      ['Song', 'Interview', 'News', 'Historical', 'Podcast', 'Talk Radio', 'Advertisement']
    end

    def multimedia
      ['Presentation', 'Game', 'Advertisement']
    end
  end
end
