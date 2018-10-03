# frozen_string_literal: true

class AddCompositeIndexToDeliveries < ActiveRecord::Migration
  def change
    add_index :deliveries, [:created_at, :open_events_count]
  end
end
