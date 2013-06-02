class AddLinkTrackingEnabledToApps < ActiveRecord::Migration
  def change
    add_column :apps, :link_tracking_enabled, :boolean, null: false, default: true
  end
end
