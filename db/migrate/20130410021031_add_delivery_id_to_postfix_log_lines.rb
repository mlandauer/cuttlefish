class AddDeliveryIdToPostfixLogLines < ActiveRecord::Migration
  def change
    add_column :postfix_log_lines, :delivery_id, :integer
  end
end
