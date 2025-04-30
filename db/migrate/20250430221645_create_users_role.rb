class CreateUsersRole < ActiveRecord::Migration[8.0]
  def change
    create_table :users_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end

    add_index :users_roles, [ :user_id, :role_id ], unique: true, name: 'index_users_roles_on_user_id_and_role_id'
  end
end
