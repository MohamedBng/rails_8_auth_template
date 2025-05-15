class RemoveDescriptionFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :description, :text
  end
end
