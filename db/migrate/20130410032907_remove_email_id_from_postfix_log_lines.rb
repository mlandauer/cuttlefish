# frozen_string_literal: true

class RemoveEmailIdFromPostfixLogLines < ActiveRecord::Migration[4.2]
  def change
    remove_column :postfix_log_lines, :email_id, :integer
  end
end
