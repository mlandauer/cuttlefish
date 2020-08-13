class AddIgnoreDenyListToEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :emails, :ignore_deny_list, :boolean, null: false, default: false
    change_column_default :emails, :ignore_deny_list, from: false, to: nil
  end
end
