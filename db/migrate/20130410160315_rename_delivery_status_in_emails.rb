# frozen_string_literal: true

class RenameDeliveryStatusInEmails < ActiveRecord::Migration[4.2]
  def change
    rename_column :emails, :delivery_status, :status
  end
end
