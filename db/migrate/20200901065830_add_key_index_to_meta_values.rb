class AddKeyIndexToMetaValues < ActiveRecord::Migration[5.2]
  def change
    add_index :meta_values, :key
  end
end
