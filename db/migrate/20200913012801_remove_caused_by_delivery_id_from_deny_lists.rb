class RemoveCausedByDeliveryIdFromDenyLists < ActiveRecord::Migration[5.2]
  def change
    remove_column :deny_lists, :caused_by_delivery_id, :bigint
  end
end
