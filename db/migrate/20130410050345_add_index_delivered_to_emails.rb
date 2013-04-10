class AddIndexDeliveredToEmails < ActiveRecord::Migration
  def change
    add_index :emails, :delivered
  end
end
