class RevertAddKeyIndexToMetaValues < ActiveRecord::Migration[5.2]
  def change
    remove_index :meta_values, :key
  end
end
