class AddOpenTrackedToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :open_tracked, :boolean, null: false, default: false
  end
end
