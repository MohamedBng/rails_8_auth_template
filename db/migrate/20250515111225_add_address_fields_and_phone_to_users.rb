class AddAddressFieldsAndPhoneToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :street, :string
    add_column :users, :postal_code, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_column :users, :description, :text
  end
end
