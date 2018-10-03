# frozen_string_literal: true

class RenameDeliveryStatusInEmails < ActiveRecord::Migration
  def change
    rename_column :emails, :delivery_status, :status
  end
end
