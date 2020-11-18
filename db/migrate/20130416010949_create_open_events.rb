# frozen_string_literal: true

class CreateOpenEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :open_events do |t|
      t.integer :delivery_id

      t.timestamps
    end
  end
end
