class Classification < ActiveRecord::Base

  validates :name, presence: true, uniqueness: { scope: :content_type }

  class << self

    def seed
      StructuralClassification.seed
      TopicalClassification.seed
    end
  end
end
