class RemoveSettingsTable < ActiveRecord::Migration
  def change
    drop_table "settings" do |t|
      t.string   "var",                   null: false
      t.text     "value"
      t.integer  "thing_id"
      t.string   "thing_type", limit: 30
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
