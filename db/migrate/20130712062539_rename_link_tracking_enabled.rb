class RenameLinkTrackingEnabled < ActiveRecord::Migration
  def change
    rename_column :apps, :link_tracking_enabled, :click_tracking_enabled
  end
end
