# frozen_string_literal: true

class AddNameToAdmins < ActiveRecord::Migration[4.2]
  def change
    add_column :admins, :name, :string
  end
end
