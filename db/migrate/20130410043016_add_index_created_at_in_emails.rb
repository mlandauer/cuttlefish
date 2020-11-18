# frozen_string_literal: true

class AddIndexCreatedAtInEmails < ActiveRecord::Migration[4.2]
  def change
    add_index :emails, :created_at
  end
end
