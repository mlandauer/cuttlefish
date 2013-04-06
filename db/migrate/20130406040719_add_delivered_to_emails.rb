class AddDeliveredToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :delivered, :boolean
    add_column :emails, :not_delivered, :boolean
  end
end
