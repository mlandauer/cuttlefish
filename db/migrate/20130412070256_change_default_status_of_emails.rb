# frozen_string_literal: true

class ChangeDefaultStatusOfEmails < ActiveRecord::Migration[4.2]
  def change
    change_column :emails, :status, :string, null: false, default: "not_sent"
  end
end
