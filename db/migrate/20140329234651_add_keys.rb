class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "identities", "providers", name: "identities_provider_id_fk"
    add_foreign_key "identities", "users", name: "identities_user_id_fk"
    add_foreign_key "links", "providers", name: "links_provider_id_fk"
    add_foreign_key "links", "users", name: "links_user_id_fk"
    add_index :links, [ :description, :domain, :title ], unique: true, length: { description: 100, title: 100 }
  end
end
