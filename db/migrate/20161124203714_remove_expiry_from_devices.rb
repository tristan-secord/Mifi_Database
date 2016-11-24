class RemoveExpiryFromDevices < ActiveRecord::Migration[5.0]
  def change
  	remove_column :devices, :expiry
  end
end
