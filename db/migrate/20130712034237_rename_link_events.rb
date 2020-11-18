# frozen_string_literal: true

class RenameLinkEvents < ActiveRecord::Migration[4.2]
  def change
    rename_table :link_events, :click_events
  end
end
