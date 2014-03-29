class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.string :domain
      t.text   :description
      t.timestamps
    end
  end
end
