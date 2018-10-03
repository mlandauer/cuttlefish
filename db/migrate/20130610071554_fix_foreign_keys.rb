# frozen_string_literal: true

class FixForeignKeys < ActiveRecord::Migration
  def change
    Delivery.find_each do |delivery|
      delivery.destroy if delivery.email.nil?
    end
  end
end
