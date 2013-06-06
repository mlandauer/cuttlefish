class UserAgentShouldBeText < ActiveRecord::Migration
  def up
    change_column :open_events, :user_agent, :text, limit: nil
  end

  def down
    change_column :open_events, :user_agent, :string
  end
end
