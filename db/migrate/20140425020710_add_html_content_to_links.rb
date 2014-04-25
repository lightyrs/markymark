class AddHtmlContentToLinks < ActiveRecord::Migration
  def change
    add_column :links, :html_content, :text, limit: 4294967295
  end
end
