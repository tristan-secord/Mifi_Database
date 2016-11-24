class AddColumn < ActiveRecord::Migration[5.0]
  def change
  	add_column :devices, :api_authtoken, :string
  	add_column :devices, :authtoken_expiry, :datetime
  end
end
