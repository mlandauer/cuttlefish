# frozen_string_literal: true

class AddCuttlefishToAppsAgain < ActiveRecord::Migration
  def change
    add_column :apps, :cuttlefish, :boolean, null: false, default: false
  end
end
