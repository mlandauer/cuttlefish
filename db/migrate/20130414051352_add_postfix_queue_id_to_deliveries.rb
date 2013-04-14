class AddPostfixQueueIdToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :postfix_queue_id, :string
    add_index :deliveries, :postfix_queue_id
    Delivery.where(sent: true).joins(:email).update_all("deliveries.postfix_queue_id = emails.postfix_queue_id")
    remove_column :emails, :postfix_queue_id
  end
end
