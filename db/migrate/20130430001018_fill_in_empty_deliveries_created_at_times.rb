class FillInEmptyDeliveriesCreatedAtTimes < ActiveRecord::Migration
  def change
    Delivery.where("deliveries.created_at IS NULL").joins(:email).update_all("deliveries.created_at = emails.created_at")
    Delivery.where("deliveries.updated_at IS NULL").joins(:email).update_all("deliveries.updated_at = emails.updated_at")
  end
end
