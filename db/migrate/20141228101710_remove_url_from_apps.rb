# frozen_string_literal: true

class RemoveUrlFromApps < ActiveRecord::Migration
  def change
    remove_column :apps, :url, :string
  end
end
