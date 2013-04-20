class AddCombinedIndexOnEmails < ActiveRecord::Migration
  def change
    add_index :emails, [:created_at, :status]
  end
end
