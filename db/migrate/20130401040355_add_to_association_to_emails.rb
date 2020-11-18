# frozen_string_literal: true

class AddToAssociationToEmails < ActiveRecord::Migration[4.2]
  def change
    remove_column :emails, :to, :string
    create_table :to_addresses_emails do |t|
      t.references :email
      t.references :email_address

      t.timestamps
    end
  end
end
