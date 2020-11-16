# frozen_string_literal: true

class AddEmailAddressIdToEmail < ActiveRecord::Migration[4.2]
  def change
    add_column :emails, :from_address_id, :integer
    remove_column :emails, :from, :string
  end
end
