# frozen_string_literal: true

class CreateLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :links do |t|
      t.string :url, null: false

      t.timestamps
    end
  end
end
