class AddIndexToDeliveries < ActiveRecord::Migration
  def change
    add_index :deliveries, :open_tracked_hash
  end
end
