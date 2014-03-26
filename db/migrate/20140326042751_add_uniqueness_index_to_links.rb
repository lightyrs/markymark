class AddUniquenessIndexToLinks < ActiveRecord::Migration
  def change
  	add_index :links, [ :user_id, :url ], unique: true, length: { url: 100 }
  end
end
