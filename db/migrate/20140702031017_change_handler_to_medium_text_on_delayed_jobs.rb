# frozen_string_literal: true

class ChangeHandlerToMediumTextOnDelayedJobs < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      change_column :delayed_jobs, :handler, :mediumtext
    end
  end
end
