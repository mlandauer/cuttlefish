class AddLinkTrackingEnabledToApps < ActiveRecord::Migration
  def change
    add_column :apps, :link_tracking_enabled, :boolean, null: false, default: true
    rename_column :apps, :open_tracking_domain, :custom_tracking_domain
  end
end
