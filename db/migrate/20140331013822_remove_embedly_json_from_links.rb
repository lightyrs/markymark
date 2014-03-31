class RemoveEmbedlyJsonFromLinks < ActiveRecord::Migration
  def up
  	remove_column :links, :embedly_json
  end

  def down
  	add_column :links, :embedly_json, :text
  end
end
