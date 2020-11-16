# frozen_string_literal: true

class AddArchivedDeliveriesCountToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :archived_deliveries_count, :integer, null: false, default: 0
  end
end
