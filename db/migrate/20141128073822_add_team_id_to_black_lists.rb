# frozen_string_literal: true

class AddTeamIdToBlackLists < ActiveRecord::Migration[4.2]
  def change
    add_reference :black_lists, :team, index: true, null: false, default: 1
    reversible do |dir|
      dir.up do
        change_column_default :black_lists, :team_id, nil
      end

      dir.down do
        change_column_default :black_lists, :team_id, 1
      end
    end
  end
end
