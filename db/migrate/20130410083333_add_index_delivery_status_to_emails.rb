# frozen_string_literal: true

class AddIndexDeliveryStatusToEmails < ActiveRecord::Migration[4.2]
  def change
    add_index :emails, :delivery_status
  end
end
