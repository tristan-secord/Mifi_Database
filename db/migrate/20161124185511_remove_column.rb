class RemoveColumn < ActiveRecord::Migration[5.0]
  def change
  	remove_column :users, :api_authtoken
  	remove_column :users, :authtoken_expiry
  end
end
