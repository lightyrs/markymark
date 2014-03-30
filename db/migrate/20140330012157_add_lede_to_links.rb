class AddLedeToLinks < ActiveRecord::Migration
  def change
    add_column :links, :lede, :text
  end
end
