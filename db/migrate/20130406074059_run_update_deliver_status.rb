class RunUpdateDeliverStatus < ActiveRecord::Migration
  def up
    Email.all.each do |email|
      email.update_delivery_status!
    end
  end
end
