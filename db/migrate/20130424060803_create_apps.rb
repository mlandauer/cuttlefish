# frozen_string_literal: true

class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.string :description
      t.string :url
      t.string :smtp_password
      t.string :open_tracking_domain

      t.timestamps
    end
  end
end
