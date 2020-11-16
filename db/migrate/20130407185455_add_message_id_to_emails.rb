# frozen_string_literal: true

class AddMessageIdToEmails < ActiveRecord::Migration[4.2]
  def change
    add_column :emails, :message_id, :string
  end
end
