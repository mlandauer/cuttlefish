# frozen_string_literal: true

class AddCompositeIndexToDeliveries < ActiveRecord::Migration[4.2]
  def change
    add_index :deliveries, [:created_at, :open_events_count]
  end
end
