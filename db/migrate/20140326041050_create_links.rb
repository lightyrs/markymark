class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.text :title
      t.text :description
      t.text :url
      t.text :image_url
      t.text :content
      t.string :domain
      t.datetime :posted_at

      t.belongs_to :user

      t.timestamps
    end
  end
end
