class AddIndexToAddresses < ActiveRecord::Migration
  def change
    add_index :addresses, :text
  end
end
