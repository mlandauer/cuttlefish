class AddCompIndexToDeliveries < ActiveRecord::Migration
  def change
    add_index :deliveries, [:created_at, :id]
  end
end
