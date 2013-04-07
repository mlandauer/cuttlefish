class AddStructuredDataInPostfixLogLines < ActiveRecord::Migration
  def change
    add_column :postfix_log_lines, :to, :string
    add_column :postfix_log_lines, :relay, :string
    add_column :postfix_log_lines, :delay, :string
    add_column :postfix_log_lines, :delays, :string
    add_column :postfix_log_lines, :dsn, :string
    add_column :postfix_log_lines, :status, :text, :limit => nil
    PostfixLogLine.reset_column_information
    PostfixLogLine.all.each do |l|
      l.update_attributes!(l.main_content_info)
    end
  end
end
