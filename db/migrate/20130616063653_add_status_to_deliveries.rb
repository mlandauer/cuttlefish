# frozen_string_literal: true

class AddStatusToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :status, :string, null: false
    Delivery.reset_column_information
    Delivery.find_each do |delivery|
      # Activerecord callbacks will not be called
      delivery.update_columns(status: delivery.calculated_status)
    end
  end
end
