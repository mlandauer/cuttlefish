# frozen_string_literal: true

class RemoveNotDeliveredFromEmails < ActiveRecord::Migration[4.2]
  def change
    remove_column :emails, :not_delivered, :boolean
  end
end
