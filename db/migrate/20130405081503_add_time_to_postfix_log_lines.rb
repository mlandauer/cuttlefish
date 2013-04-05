class AddTimeToPostfixLogLines < ActiveRecord::Migration
  def change
    add_column :postfix_log_lines, :time, :datetime
  end
end
