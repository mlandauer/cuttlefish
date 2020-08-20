class CreateMetaValues < ActiveRecord::Migration[5.2]
  def change
    create_table :meta_values do |t|
      t.references :email, null: false, foreign_key: true
      t.string :key, null: false
      t.string :value, null: false
    end
    add_index :meta_values, [:email_id, :key], unique: true
  end
end
