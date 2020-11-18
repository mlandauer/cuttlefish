# frozen_string_literal: true

class AddOpenTrackedHashToDeliveries < ActiveRecord::Migration[4.2]
  def change
    add_column :deliveries, :open_tracked_hash, :string
  end
end
