class StructuralClassification < Classification

  class << self

    def seed
      content_types.each do |content_type, names|
        names.each do |name|
          find_or_create_by(name: "#{name}", content_type: "#{content_type}")
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
      ['News', 'Interview', 'Speech', 'List', 'Review', 'Tutorial', 'Comparison', 'Case Study', 'Rant', 'Story', 'Prediction', 'Press Release', 'Analysis', 'Live Blog', 'Q&A', 'Contest', 'Transcription', 'Summary', 'Advice', 'Guide', 'Round Up', 'Op-Ed', 'Comment', 'Historical', 'Status', 'Code', 'Technical', 'E-book', 'Advertisement']
    end

    def image
      ['Infographic', 'Slideshow', 'News', 'Advertisement']
    end

    def video
      ['Webisode', 'Vlog', 'Music Video', 'Concert', 'Movie Trailer', 'TV Show', 'Movie', 'Commercial', 'News', 'Historical', 'Podcast', 'Interview', 'Speech', 'Tutorial', 'Review', 'Press Release', 'Live Stream', 'Advertisement']
    end

    def audio
      ['Song', 'Album', 'Soundtrack', 'Concert', 'Speech', 'Live Stream', 'Interview', 'News', 'Historical', 'Podcast', 'Talk Radio', 'Advertisement']
    end

    def multimedia
      ['Presentation', 'Game', 'Advertisement']
    end
  end
end
