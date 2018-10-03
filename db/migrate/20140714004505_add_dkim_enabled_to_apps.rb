# frozen_string_literal: true

class AddDkimEnabledToApps < ActiveRecord::Migration
  def change
    add_column :apps, :dkim_enabled, :boolean, null: false, default: false
  end
end
