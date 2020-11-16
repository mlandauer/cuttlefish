# frozen_string_literal: true

class CreateEmailAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :email_addresses do |t|
      t.string :address

      t.timestamps
    end
  end
end
