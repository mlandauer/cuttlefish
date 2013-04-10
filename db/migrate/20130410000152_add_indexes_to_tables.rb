class AddIndexesToTables < ActiveRecord::Migration
  def change
    add_index :emails, :postfix_queue_id
    add_index :postfix_log_lines, :time
  end
end
