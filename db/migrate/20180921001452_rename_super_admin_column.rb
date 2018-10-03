# frozen_string_literal: true

class RenameSuperAdminColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :admins, :super_admin, :site_admin
  end
end
