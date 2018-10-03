# frozen_string_literal: true

class AddCuttlefishToApps < ActiveRecord::Migration
  def change
    add_column :apps, :cuttlefish, :boolean, null: false, default: false
  end
end
