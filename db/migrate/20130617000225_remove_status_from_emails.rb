# frozen_string_literal: true

class RemoveStatusFromEmails < ActiveRecord::Migration
  def change
    remove_column :emails, :status
  end
end
