# frozen_string_literal: true

class RenameCuttlefishFieldInApps < ActiveRecord::Migration
  def change
    rename_column :apps, :cuttlefish, :default_app
  end
end
