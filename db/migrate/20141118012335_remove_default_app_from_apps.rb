class RemoveDefaultAppFromApps < ActiveRecord::Migration
  def change
    remove_column :apps, :default_app, :boolean, default: false, null: false
  end
end
