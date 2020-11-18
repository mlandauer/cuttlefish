# frozen_string_literal: true

class AddOpenTrackingEnabledToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :open_tracking_enabled, :boolean, null: false, default: true
  end
end
