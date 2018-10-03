# frozen_string_literal: true

class AddDefaultToDeliveryStatusInEmails < ActiveRecord::Migration
  def change
    change_column :emails, :delivery_status, :string, null: false, default: "unknown"
  end
end
