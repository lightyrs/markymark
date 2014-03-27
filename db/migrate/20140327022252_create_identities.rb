class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :provider
      t.string :uid
      t.string :username

      t.belongs_to :user
      
      t.timestamps
    end
  end
end
