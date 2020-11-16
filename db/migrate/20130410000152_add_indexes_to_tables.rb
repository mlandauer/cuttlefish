# frozen_string_literal: true

class AddIndexesToTables < ActiveRecord::Migration[4.2]
  def change
    add_index :emails, :postfix_queue_id
    add_index :postfix_log_lines, :time
  end
end
