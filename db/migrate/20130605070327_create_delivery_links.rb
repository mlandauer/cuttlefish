# frozen_string_literal: true

class CreateDeliveryLinks < ActiveRecord::Migration
  def change
    create_table :delivery_links do |t|
      t.integer :delivery_id, null: false
      t.integer :link_id, null: false

      t.timestamps
    end
  end
end
