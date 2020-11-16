# frozen_string_literal: true

class AddCuttlefishToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :cuttlefish, :boolean, null: false, default: false
  end
end
