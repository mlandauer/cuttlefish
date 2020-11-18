# frozen_string_literal: true

class ConvertStringToTextInPostfixLogLines < ActiveRecord::Migration[4.2]
  def up
    change_column :postfix_log_lines, :text, :text, limit: nil
  end

  def down
    change_column :postfix_log_lines, :text, :string
  end
end
