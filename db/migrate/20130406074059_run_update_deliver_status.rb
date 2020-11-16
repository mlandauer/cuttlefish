# frozen_string_literal: true

class RunUpdateDeliverStatus < ActiveRecord::Migration[4.2]
  def up
    Email.all.each do |email|
      email.update_status!
    end
  end
end
