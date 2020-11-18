# frozen_string_literal: true

class UpdateAppIdInDeliveries < ActiveRecord::Migration[4.2]
  def change
    #Delivery.connection.execute('UPDATE deliveries JOIN emails ON deliveries.email_id = emails.id SET deliveries.app_id = emails.app_id')
  end
end
