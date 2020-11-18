# frozen_string_literal: true

class CleanupPostfixLogLines < ActiveRecord::Migration[4.2]
  def change
    remove_column :postfix_log_lines, :text, :text
    remove_column :postfix_log_lines, :to, :string
    rename_column :postfix_log_lines, :status, :extended_status
  end
end
