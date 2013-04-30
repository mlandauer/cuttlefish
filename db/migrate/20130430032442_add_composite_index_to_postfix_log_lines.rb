class AddCompositeIndexToPostfixLogLines < ActiveRecord::Migration
  def change
    add_index :postfix_log_lines, [:delivery_id, :time]
  end
end
