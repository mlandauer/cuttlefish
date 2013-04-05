class ConvertStringToTextInPostfixLogLines < ActiveRecord::Migration
  def up
    change_column :postfix_log_lines, :text, :text, :limit => nil
  end

  def down
    change_column :postfix_log_lines, :text, :string
  end
end
