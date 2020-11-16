# frozen_string_literal: true

class AddIndexToDeliveries < ActiveRecord::Migration[4.2]
  def change
    add_index :deliveries, :open_tracked_hash
  end
end
