# frozen_string_literal: true

class FixForeignKeys < ActiveRecord::Migration[4.2]
  def change
    Delivery.find_each do |delivery|
      delivery.destroy if delivery.email.nil?
    end
  end
end
