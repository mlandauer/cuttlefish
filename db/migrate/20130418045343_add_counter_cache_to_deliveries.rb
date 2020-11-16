# frozen_string_literal: true

class AddCounterCacheToDeliveries < ActiveRecord::Migration[4.2]
  def change
    add_column :deliveries, :open_events_count, :integer, null: false, default: 0
    # reset cached counts for deliveries with open_events only
    ids = Set.new
    OpenEvent.all.each {|e| ids << e.delivery_id}
    ids.each do |id|
      Delivery.reset_counters(id, :open_events)
    end
  end
end
