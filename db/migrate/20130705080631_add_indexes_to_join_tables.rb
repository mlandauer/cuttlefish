# frozen_string_literal: true

class AddIndexesToJoinTables < ActiveRecord::Migration[4.2]
  def change
    add_index :delivery_links, :delivery_id
    add_index :delivery_links, :link_id
    add_index :link_events, :delivery_link_id
  end
end
