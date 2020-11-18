# frozen_string_literal: true

class AllowNullTeamIdInApps < ActiveRecord::Migration[4.2]
  def change
    change_column :apps, :team_id, :integer, null: true
  end
end
