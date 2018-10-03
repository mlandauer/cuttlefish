# frozen_string_literal: true

class RenameAddressInAddresses < ActiveRecord::Migration
  def change
    rename_column :addresses, :address, :text
  end
end
