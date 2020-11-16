# frozen_string_literal: true

class AddPasswordLockedToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :smtp_password_locked, :boolean, null: false, default: false
  end
end
