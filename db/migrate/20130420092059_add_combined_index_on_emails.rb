# frozen_string_literal: true

class AddCombinedIndexOnEmails < ActiveRecord::Migration[4.2]
  def change
    add_index :emails, [:created_at, :status]
  end
end
