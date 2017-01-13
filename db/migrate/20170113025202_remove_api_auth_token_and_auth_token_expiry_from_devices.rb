class RemoveApiAuthTokenAndAuthTokenExpiryFromDevices < ActiveRecord::Migration[5.0]
  def change
    remove_column :devices, :api_authtoken
    remove_column :devices, :authtoken_expiry
  end
end
