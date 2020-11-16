# frozen_string_literal: true

class AddTimeToPostfixLogLines < ActiveRecord::Migration[4.2]
  def change
    add_column :postfix_log_lines, :time, :datetime
  end
end
