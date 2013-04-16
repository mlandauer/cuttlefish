class CreateOpenEvents < ActiveRecord::Migration
  def change
    create_table :open_events do |t|
      t.integer :delivery_id

      t.timestamps
    end
  end
end
