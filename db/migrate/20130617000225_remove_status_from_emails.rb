# frozen_string_literal: true

class RemoveStatusFromEmails < ActiveRecord::Migration[4.2]
  def change
    remove_column :emails, :status
  end
end
