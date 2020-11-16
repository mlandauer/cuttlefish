# frozen_string_literal: true

class AddForeignKeyConstraintsToEmails < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key(:emails, :apps, dependent: :delete)
    add_foreign_key(:emails, :addresses, column: 'from_address_id')
  end
end
