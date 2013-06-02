class AddOpenTrackingEnabledToApps < ActiveRecord::Migration
  def change
    add_column :apps, :open_tracking_enabled, :boolean, null: false, default: true
  end
end
