class AddStiSupportToClassifications < ActiveRecord::Migration
  def change
    add_column :classifications, :type, :string
  end
end
