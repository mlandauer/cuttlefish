# frozen_string_literal: true

class AddForeignKeyConstraintsToPostfixLogLines < ActiveRecord::Migration[4.2]
  def change
    # Remove any postfix_log_lines that don't belong to a delivery anymore
    non_existing_ids = PostfixLogLine.distinct(:delivery_id).pluck(:delivery_id) - Delivery.pluck(:id)
    PostfixLogLine.where(delivery_id: non_existing_ids).delete_all

    add_foreign_key(:postfix_log_lines, :deliveries, dependent: :delete)
  end
end
