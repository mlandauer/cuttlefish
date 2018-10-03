# frozen_string_literal: true

class AllowNullTeamIdInApps < ActiveRecord::Migration
  def change
    change_column :apps, :team_id, :integer, null: true
  end
end
