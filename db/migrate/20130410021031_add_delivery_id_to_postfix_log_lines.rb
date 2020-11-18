# frozen_string_literal: true

class AddDeliveryIdToPostfixLogLines < ActiveRecord::Migration[4.2]
  def change
    add_column :postfix_log_lines, :delivery_id, :integer

    PostfixLogLine.reset_column_information
    PostfixLogLine.all.each do |line|
      address = Address.find_by_text(line.to)
      delivery = line.email.deliveries.find_by_address_id(address.id) if address
      line.update_attribute(:delivery_id, delivery.id) if delivery
    end
  end
end
