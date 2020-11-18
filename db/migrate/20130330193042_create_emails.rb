# frozen_string_literal: true

class CreateEmails < ActiveRecord::Migration[4.2]
  def change
    create_table :emails do |t|
      t.string :from
      t.string :to

      t.timestamps
    end
  end
end
