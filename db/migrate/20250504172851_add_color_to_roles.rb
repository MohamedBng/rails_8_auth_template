class AddColorToRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :roles, :color, :string
  end
end
