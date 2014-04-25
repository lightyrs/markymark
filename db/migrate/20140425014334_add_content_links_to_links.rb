class AddContentLinksToLinks < ActiveRecord::Migration
  def change
    add_column :links, :content_links, :text, limit: 4294967295
  end
end
