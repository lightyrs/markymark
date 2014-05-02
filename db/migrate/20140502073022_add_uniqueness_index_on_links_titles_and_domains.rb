class AddUniquenessIndexOnLinksTitlesAndDomains < ActiveRecord::Migration
  def change
    add_index :links, [ :domain, :title ], unique: true, length: { title: 50 }
  end
end
