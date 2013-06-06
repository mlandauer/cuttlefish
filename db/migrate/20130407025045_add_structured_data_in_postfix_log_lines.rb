class AddStructuredDataInPostfixLogLines < ActiveRecord::Migration
  def change
    add_column :postfix_log_lines, :to, :string
    add_column :postfix_log_lines, :relay, :string
    add_column :postfix_log_lines, :delay, :string
    add_column :postfix_log_lines, :delays, :string
    add_column :postfix_log_lines, :dsn, :string
    add_column :postfix_log_lines, :status, :text, limit: nil
    PostfixLogLine.reset_column_information
    PostfixLogLine.all.each do |l|
      to_match = l.text.match(/to=<([^>]+)>/)
      relay_match = l.text.match(/relay=([^,]+)/)
      delay_match = l.text.match(/delay=([^,]+)/)
      delays_match = l.text.match(/delays=([^,]+)/)
      dsn_match = l.text.match(/dsn=([^,]+)/)
      status_match = l.text.match(/status=(.*)$/)
      l.update_attributes!(
        to: (to_match[1] if to_match),
        relay: (relay_match[1] if relay_match),
        delay: (delay_match[1] if delay_match),
        delays: (delays_match[1] if delays_match),
        dsn: (dsn_match[1] if dsn_match),
        status: (status_match[1] if status_match)
      )
    end
  end
end
