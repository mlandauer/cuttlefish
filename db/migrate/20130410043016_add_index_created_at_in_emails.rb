# frozen_string_literal: true

class AddIndexCreatedAtInEmails < ActiveRecord::Migration
  def change
    add_index :emails, :created_at
  end
end
