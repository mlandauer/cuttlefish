# frozen_string_literal: true

class AddEmailAddressIdToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :from_address_id, :integer
    remove_column :emails, :from, :string
  end
end
