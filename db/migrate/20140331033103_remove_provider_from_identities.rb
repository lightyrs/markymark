class RemoveProviderFromIdentities < ActiveRecord::Migration
  def up
  	remove_column :identities, :provider
  end

  def down
  	add_column :identities, :provider, :string
  end  
end
