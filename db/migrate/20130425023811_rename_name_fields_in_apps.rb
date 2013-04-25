class RenameNameFieldsInApps < ActiveRecord::Migration
  def change
    rename_column :apps, :name, :smtp_username
    rename_column :apps, :description, :name
  end
end
