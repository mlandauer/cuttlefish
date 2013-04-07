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
      l.update_attributes!(
        to: l.text.match(/to=<([^>]+)>/)[1],
        relay: l.text.match(/relay=([^,]+)/)[1],
        delay: l.text.match(/delay=([^,]+)/)[1],
        delays: l.text.match(/delays=([^,]+)/)[1],
        dsn: l.text.match(/dsn=([^,]+)/)[1],
        status: l.text.match(/status=(.*)$/)[1]
      )
    end
  end
end
