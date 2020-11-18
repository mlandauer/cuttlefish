# frozen_string_literal: true

class RemoveUrlFromApps < ActiveRecord::Migration[4.2]
  def change
    remove_column :apps, :url, :string
  end
end
