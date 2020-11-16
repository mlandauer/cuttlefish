# frozen_string_literal: true

class AddAppIdIndexToDeliveries < ActiveRecord::Migration[4.2]
  def change
    add_index :deliveries, :app_id
  end
end
