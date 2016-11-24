class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
   		t.integer :user_id
   		t.string :device_id
   		t.string :device_type
   		t.datetime :expiry
   		t.timestamps
    end
  end
end
