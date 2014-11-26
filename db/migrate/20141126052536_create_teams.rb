class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|

      t.timestamps
    end
  end
end
