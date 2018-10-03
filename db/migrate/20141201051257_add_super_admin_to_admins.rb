# frozen_string_literal: true

class AddSuperAdminToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :super_admin, :boolean, null: false, default: false
  end
end
