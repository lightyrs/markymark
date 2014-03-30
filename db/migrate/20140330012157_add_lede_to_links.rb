class AddLedeToLinks < ActiveRecord::Migration
  def change
    add_columns :links, :lede, :text
  end
end
