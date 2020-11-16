# frozen_string_literal: true

class RenameAddressInAddresses < ActiveRecord::Migration[4.2]
  def change
    rename_column :addresses, :address, :text
  end
end
