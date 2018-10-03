# frozen_string_literal: true

class AddIndexDeliveryStatusToEmails < ActiveRecord::Migration
  def change
    add_index :emails, :delivery_status
  end
end
