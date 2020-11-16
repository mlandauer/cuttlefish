# frozen_string_literal: true

class AddSubjectToEmails < ActiveRecord::Migration[4.2]
  def change
    add_column :emails, :subject, :string
  end
end
