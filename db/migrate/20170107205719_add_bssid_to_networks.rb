class AddBssidToNetworks < ActiveRecord::Migration[5.0]
  def change
    add_column :networks, :bssid, :string
  end
end
