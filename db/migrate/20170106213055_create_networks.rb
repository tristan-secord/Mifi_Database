class CreateNetworks < ActiveRecord::Migration[5.0]
  def change
    create_table :networks do |t|
      t.string :name

      t.string :password_hash
      t.string :password_salt

      t.boolean :discoverable, :default => true

      t.timestamps
    end
  end
end
