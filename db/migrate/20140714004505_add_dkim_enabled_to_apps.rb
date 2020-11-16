# frozen_string_literal: true

class AddDkimEnabledToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :dkim_enabled, :boolean, null: false, default: false
  end
end
