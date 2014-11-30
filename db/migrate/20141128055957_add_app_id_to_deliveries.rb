class AddAppIdToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :app_id, :integer
    #add_index :deliveries, :app_id
    #Delivery.connection.execute('UPDATE deliveries JOIN emails ON deliveries.email_id = emails.id SET deliveries.app_id = emails.app_id')
  end
end
