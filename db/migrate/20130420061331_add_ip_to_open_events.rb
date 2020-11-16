# frozen_string_literal: true

class AddIpToOpenEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :open_events, :ip, :string
  end
end
