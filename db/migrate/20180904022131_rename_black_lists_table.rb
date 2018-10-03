# frozen_string_literal: true

class RenameBlackListsTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :black_lists, :deny_lists
  end
end
