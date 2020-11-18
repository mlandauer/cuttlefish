# frozen_string_literal: true

class RemoveDeliveredFromEmails < ActiveRecord::Migration[4.2]
  def change
    remove_column :emails, :delivered, :boolean
  end
end
