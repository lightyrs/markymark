class AddUniquenessIndexToClassifications < ActiveRecord::Migration
  def change
    add_index :classifications, [ :content_type, :name ], unique: true
  end
end
