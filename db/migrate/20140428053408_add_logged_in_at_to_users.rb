class AddLoggedInAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :logged_in_at, :datetime
  end
end
