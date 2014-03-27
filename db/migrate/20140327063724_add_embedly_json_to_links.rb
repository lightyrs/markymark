class AddEmbedlyJsonToLinks < ActiveRecord::Migration
  def change
  	add_column :links, :embedly_json, :text
  end
end
