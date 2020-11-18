# frozen_string_literal: true

class RemoveDefaultAppFromApps < ActiveRecord::Migration[4.2]
  def change
    remove_column :apps, :default_app, :boolean, default: false, null: false
  end
end
