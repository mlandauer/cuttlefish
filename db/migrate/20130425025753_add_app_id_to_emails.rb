# frozen_string_literal: true

class AddAppIdToEmails < ActiveRecord::Migration[4.2]
  def change
    add_column :emails, :app_id, :integer
  end
end
