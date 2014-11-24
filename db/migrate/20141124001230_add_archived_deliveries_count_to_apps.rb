class AddArchivedDeliveriesCountToApps < ActiveRecord::Migration
  def change
    add_column :apps, :archived_deliveries_count, :integer, null: false, default: 0
  end
end
