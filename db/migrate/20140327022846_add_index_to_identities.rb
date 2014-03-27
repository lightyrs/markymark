class AddIndexToIdentities < ActiveRecord::Migration
  def change
  	add_index :identities, :user_id
  end
end
