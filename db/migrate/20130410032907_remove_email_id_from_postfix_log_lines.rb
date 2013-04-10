class RemoveEmailIdFromPostfixLogLines < ActiveRecord::Migration
  def change
    remove_column :postfix_log_lines, :email_id, :integer
  end
end
