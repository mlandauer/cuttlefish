# frozen_string_literal: true

class RenameCuttlefishFieldInApps < ActiveRecord::Migration[4.2]
  def change
    rename_column :apps, :cuttlefish, :default_app
  end
end
