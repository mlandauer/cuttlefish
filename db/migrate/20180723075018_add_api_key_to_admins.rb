# frozen_string_literal: true

class AddApiKeyToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :api_key, :string
    Admin.reset_column_information
    reversible do |dir|
      dir.up do
        Admin.all.each do |admin|
          admin.set_api_key
          admin.save!
        end
      end
    end
  end
end
