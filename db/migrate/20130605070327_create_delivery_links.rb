# frozen_string_literal: true

class CreateDeliveryLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :delivery_links do |t|
      t.integer :delivery_id, null: false
      t.integer :link_id, null: false

      t.timestamps
    end
  end
end
