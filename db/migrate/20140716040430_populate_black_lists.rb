# frozen_string_literal: true

class PopulateBlackLists < ActiveRecord::Migration
  def change
    Address.all.each do |address|
      # Duplicate logic in Address#status
      most_recent_log_line = address.postfix_log_lines.order("time DESC").first

      if most_recent_log_line && most_recent_log_line.status == "hard_bounce"
        BlackList.create(address: address, caused_by_delivery: most_recent_log_line.delivery)
      end
    end
  end
end
