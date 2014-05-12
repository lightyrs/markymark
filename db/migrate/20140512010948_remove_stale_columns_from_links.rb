class RemoveStaleColumnsFromLinks < ActiveRecord::Migration
  def up
    remove_column :links, :metainspector_page
    remove_column :links, :pismo_page
    add_column    :links, :completed, :boolean, default: false
  end

  def down
    remove_column :links, :completed
    add_column :links, :metainspector_page, :text
    add_column :links, :pismo_page, :text
  end
end
