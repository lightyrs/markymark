class ChangeLinksContentLimit < ActiveRecord::Migration
  def change
  	change_column :links, :content, :text, limit: 4294967295
  end
end
