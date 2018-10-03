# frozen_string_literal: true

class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :from
      t.string :to

      t.timestamps
    end
  end
end
