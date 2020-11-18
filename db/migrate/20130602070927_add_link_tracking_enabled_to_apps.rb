# frozen_string_literal: true

class AddLinkTrackingEnabledToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :link_tracking_enabled, :boolean, null: false, default: true
    rename_column :apps, :open_tracking_domain, :custom_tracking_domain
  end
end
