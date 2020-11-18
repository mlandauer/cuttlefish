# frozen_string_literal: true

class RenameNameFieldsInApps < ActiveRecord::Migration[4.2]
  def change
    rename_column :apps, :name, :smtp_username
    rename_column :apps, :description, :name
  end
end
