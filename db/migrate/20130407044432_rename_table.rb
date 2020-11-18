# frozen_string_literal: true

class RenameTable < ActiveRecord::Migration[4.2]
  def change
    rename_table :to_addresses_emails, :deliveries
  end
end
