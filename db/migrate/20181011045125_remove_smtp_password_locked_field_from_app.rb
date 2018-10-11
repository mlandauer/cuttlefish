class RemoveSmtpPasswordLockedFieldFromApp < ActiveRecord::Migration[5.2]
  def change
    remove_column :apps, :smtp_password_locked, :boolean, default: false, null: false
  end
end
