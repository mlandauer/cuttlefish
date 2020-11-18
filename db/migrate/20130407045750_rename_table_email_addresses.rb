# frozen_string_literal: true

class RenameTableEmailAddresses < ActiveRecord::Migration[4.2]
  def change
    rename_table :email_addresses, :addresses
    rename_column :deliveries, :email_address_id, :address_id
  end
end
