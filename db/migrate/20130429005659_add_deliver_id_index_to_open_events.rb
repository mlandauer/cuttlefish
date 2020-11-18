# frozen_string_literal: true

class AddDeliverIdIndexToOpenEvents < ActiveRecord::Migration[4.2]
  def change
    add_index :open_events, :delivery_id
  end
end
