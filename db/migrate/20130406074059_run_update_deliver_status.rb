class RunUpdateDeliverStatus < ActiveRecord::Migration
  def up
    Email.all.each do |email|
      email.update_status!
    end
  end
end
