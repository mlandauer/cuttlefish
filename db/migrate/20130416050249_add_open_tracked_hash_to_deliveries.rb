class AddOpenTrackedHashToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :open_tracked_hash, :string
  end
end
