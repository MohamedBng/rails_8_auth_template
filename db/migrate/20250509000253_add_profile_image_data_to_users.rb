class AddProfileImageDataToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :profile_image_data, :jsonb
  end
end
