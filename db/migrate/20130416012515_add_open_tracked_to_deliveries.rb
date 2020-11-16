# frozen_string_literal: true

class AddOpenTrackedToDeliveries < ActiveRecord::Migration[4.2]
  def change
    add_column :deliveries, :open_tracked, :boolean, null: false, default: false
  end
end
