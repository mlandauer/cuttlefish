# frozen_string_literal: true

class AddDataHashToEmails < ActiveRecord::Migration[4.2]
  def change
    add_column :emails, :data_hash, :string
  end
end
