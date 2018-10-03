# frozen_string_literal: true

class AddIndexToDeliveriesJoinTable < ActiveRecord::Migration
  def change
    add_index :deliveries, [:email_id, :address_id]
  end
end
