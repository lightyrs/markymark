class CreateClassifications < ActiveRecord::Migration
  def change
    create_table :classifications do |t|
      t.string :name
      t.string :content_type
      t.text :description

      t.timestamps
    end
  end
end
