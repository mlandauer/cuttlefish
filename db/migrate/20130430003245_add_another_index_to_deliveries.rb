class AddAnotherIndexToDeliveries < ActiveRecord::Migration
  def change
    add_index :deliveries, [:open_tracked, :created_at]
  end
end
