class DropDenyLists < ActiveRecord::Migration[5.2]
  def change
    drop_table "deny_lists" do |t|
      t.integer "address_id"
      t.integer "caused_by_delivery_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "team_id", null: false
      t.index ["team_id"], name: "index_deny_lists_on_team_id"
    end
  end
end
