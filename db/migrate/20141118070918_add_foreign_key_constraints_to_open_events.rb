class AddForeignKeyConstraintsToOpenEvents < ActiveRecord::Migration
  def change
    add_foreign_key(:open_events, :deliveries, dependent: :delete)
  end
end
