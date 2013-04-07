class RenameTableEmailAddresses < ActiveRecord::Migration
  def change
    rename_table :email_addresses, :addresses
    rename_column :deliveries, :email_address_id, :address_id
  end
end
