# frozen_string_literal: true

class AddUserAgentToOpenEvents < ActiveRecord::Migration
  def change
    add_column :open_events, :user_agent, :string
  end
end
