class AddLatitudeAndLongitudeToNetworks < ActiveRecord::Migration[5.0]
  def change
    add_column :networks, :latitude, :float
    add_column :networks, :longitude, :float
  end
end
