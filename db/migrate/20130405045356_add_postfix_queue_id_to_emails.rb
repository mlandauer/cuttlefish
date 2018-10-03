# frozen_string_literal: true

class AddPostfixQueueIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :postfix_queue_id, :string
  end
end
