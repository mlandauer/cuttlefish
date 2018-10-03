# frozen_string_literal: true

class AddDataHashToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :data_hash, :string
  end
end
