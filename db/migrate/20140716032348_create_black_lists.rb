# frozen_string_literal: true

class CreateBlackLists < ActiveRecord::Migration[4.2]
  def change
    create_table :black_lists do |t|
      t.integer :address_id
      t.integer :caused_by_delivery_id

      t.timestamps
    end
  end
end
