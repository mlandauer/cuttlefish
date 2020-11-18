# frozen_string_literal: true

class AddAnotherIndexToDeliveries < ActiveRecord::Migration[4.2]
  def change
    add_index :deliveries, [:open_tracked, :created_at]
  end
end
