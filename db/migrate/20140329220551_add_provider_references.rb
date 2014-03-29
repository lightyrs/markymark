class AddProviderReferences < ActiveRecord::Migration
  def change
    change_table :links do |t|
      t.belongs_to :provider
    end
    change_table :identities do |t|
      t.belongs_to :provider
    end
  end
end
