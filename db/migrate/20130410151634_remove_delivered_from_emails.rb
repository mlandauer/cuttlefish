class RemoveDeliveredFromEmails < ActiveRecord::Migration
  def change
    remove_column :emails, :delivered, :boolean
  end
end
