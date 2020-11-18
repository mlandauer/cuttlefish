# frozen_string_literal: true

class AddSuperAdminToAdmins < ActiveRecord::Migration[4.2]
  def change
    add_column :admins, :super_admin, :boolean, null: false, default: false
  end
end
