# frozen_string_literal: true

class AddDeliveredToEmails < ActiveRecord::Migration[4.2]
  def change
    add_column :emails, :delivered, :boolean
    add_column :emails, :not_delivered, :boolean
  end
end
