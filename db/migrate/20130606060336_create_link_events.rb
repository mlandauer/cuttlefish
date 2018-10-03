# frozen_string_literal: true

class CreateLinkEvents < ActiveRecord::Migration
  def change
    create_table :link_events do |t|
      t.integer :delivery_link_id
      t.text :user_agent
      t.text :referer
      t.string :ip

      t.timestamps
    end
  end
end
