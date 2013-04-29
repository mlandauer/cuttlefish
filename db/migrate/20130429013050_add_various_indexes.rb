class AddVariousIndexes < ActiveRecord::Migration
  def change
    add_index :emails, :from_address_id
    add_index :emails, :message_id
    add_index :emails, :app_id
    add_index :postfix_log_lines, :delivery_id
  end
end
