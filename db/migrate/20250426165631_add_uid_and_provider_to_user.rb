class AddUidAndProviderToUser < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :uid, :string
    add_column :users, :provider, :string
  end

  def down
    remove_column :users, :provider
    remove_column :users, :uid
  end
end
