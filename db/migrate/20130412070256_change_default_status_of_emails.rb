# frozen_string_literal: true

class ChangeDefaultStatusOfEmails < ActiveRecord::Migration
  def change
    change_column :emails, :status, :string, null: false, default: "not_sent"
  end
end
