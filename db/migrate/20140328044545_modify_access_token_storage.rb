class ModifyAccessTokenStorage < ActiveRecord::Migration
  def up
  	remove_column :users, :facebook_token
  	add_column :identities, :token, :text
  end

  def down
  	remove_column :identities, :token
  	add_column :users, :facebook_token, :text
  end
end
