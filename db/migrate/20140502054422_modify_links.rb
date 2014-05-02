class ModifyLinks < ActiveRecord::Migration
  def change
    add_column :links, :pismo_page, :text, limit: 4294967295
    add_column :links, :metainspector_page, :text, limit: 4294967295
    add_column :links, :scraped, :boolean, default: false
    change_column :links, :title, :text, limit: 4294967295
  end
end
