# frozen_string_literal: true

class AddIndexDeliveredToEmails < ActiveRecord::Migration[4.2]
  def change
    add_index :emails, :delivered
  end
end
