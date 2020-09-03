class AddAppDenyLists < ActiveRecord::Migration[5.2]
  def change
    create_table :app_deny_lists do |t|
      t.references :address, null: false, foreign_key: true
      t.references :caused_by_delivery, null: false, foreign_key: {to_table: :deliveries}
      t.references :app, null: false, foreign_key: true

      t.timestamps
    end
  end
end
