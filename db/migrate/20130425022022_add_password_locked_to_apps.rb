class AddPasswordLockedToApps < ActiveRecord::Migration
  def change
    add_column :apps, :smtp_password_locked, :boolean, null: false, default: false
  end
end
