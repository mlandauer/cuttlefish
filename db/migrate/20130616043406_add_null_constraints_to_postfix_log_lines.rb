# frozen_string_literal: true

class AddNullConstraintsToPostfixLogLines < ActiveRecord::Migration
  def change
    PostfixLogLine.where(delivery_id: nil).delete_all
    change_column :postfix_log_lines, :time, :datetime, null: false
    change_column :postfix_log_lines, :relay, :string, null: false
    change_column :postfix_log_lines, :delay, :string, null: false
    change_column :postfix_log_lines, :delays, :string, null: false
    change_column :postfix_log_lines, :dsn, :string, null: false
    change_column :postfix_log_lines, :extended_status, :text, null: false
    change_column :postfix_log_lines, :delivery_id, :integer, null: false
  end
end
