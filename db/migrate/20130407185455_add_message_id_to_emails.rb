# frozen_string_literal: true

class AddMessageIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :message_id, :string
  end
end
