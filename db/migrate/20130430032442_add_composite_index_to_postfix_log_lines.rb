# frozen_string_literal: true

class AddCompositeIndexToPostfixLogLines < ActiveRecord::Migration[4.2]
  def change
    add_index :postfix_log_lines, [:delivery_id, :time]
  end
end
