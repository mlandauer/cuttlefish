# frozen_string_literal: true

class AddTeamIdToAdmins < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        # Team that we add pre-existing admins and apps to
        Team.create!(id: 1)
      end

      dir.down do
        Team.delete(1)
      end
    end

    add_reference :admins, :team, index: true, null: false, default: 1
    #change_column :admins, :team_id, :integer, null: false
    reversible do |dir|
      dir.up do
        change_column_default :admins, :team_id, nil
      end

      dir.down do
        change_column_default :admins, :team_id, 1
      end
    end
    #t.integer  "team_id",                default: 1,  null: false
  end
end
