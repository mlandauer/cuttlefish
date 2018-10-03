# frozen_string_literal: true

class AddSentToDeliveries < ActiveRecord::Migration
  def change
    # For any preexisting rows set the value to true
    add_column :deliveries, :sent, :boolean, null: false, default: true
    # But for any new rows set the value to false
    change_column :deliveries, :sent, :boolean, null: false, default: false
  end
end
