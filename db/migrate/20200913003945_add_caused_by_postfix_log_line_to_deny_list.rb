class AddCausedByPostfixLogLineToDenyList < ActiveRecord::Migration[5.2]
  class DenyList < ActiveRecord::Base
    belongs_to :caused_by_delivery, class_name: "Delivery"
    belongs_to :caused_by_postfix_log_line, class_name: "PostfixLogLine"
  end

  def up
    add_reference :deny_lists, :caused_by_postfix_log_line,
                  foreign_key: {to_table: :postfix_log_lines}
    DenyList.find_each do |d|
      d.update!(caused_by_postfix_log_line: d.caused_by_delivery.postfix_log_lines.first)
    end
    change_column_null :deny_lists, :caused_by_postfix_log_line_id, false
    # Doing this as a step before removing the field
    change_column_null :deny_lists, :caused_by_delivery_id, true
  end

  def down
    DenyList.find_each do |d|
      d.update!(caused_by_delivery: d.caused_by_postfix_log_line.delivery)
    end
    change_column_null :deny_lists, :caused_by_delivery_id, false
    remove_reference :deny_lists, :caused_by_postfix_log_line,
                     foreign_key: {to_table: :postfix_log_lines}
  end
end
