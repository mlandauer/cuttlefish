class RenameAppDenyLists < ActiveRecord::Migration[5.2]
  def change
    rename_table :app_deny_lists, :deny_lists
  end
end
