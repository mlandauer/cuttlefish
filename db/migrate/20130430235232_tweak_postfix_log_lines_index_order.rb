# frozen_string_literal: true

class TweakPostfixLogLinesIndexOrder < ActiveRecord::Migration
  def change
    add_index :postfix_log_lines, [:time, :delivery_id]
    remove_index :postfix_log_lines, [:delivery_id, :time]
    remove_index :postfix_log_lines, :time
  end
end
