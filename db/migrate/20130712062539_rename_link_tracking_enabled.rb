# frozen_string_literal: true

class RenameLinkTrackingEnabled < ActiveRecord::Migration[4.2]
  def change
    rename_column :apps, :link_tracking_enabled, :click_tracking_enabled
  end
end
