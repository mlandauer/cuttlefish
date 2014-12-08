class ChangeHandlerToMediumTextOnDelayedJobs < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.adapter_name == 'MySQL'
      change_column :delayed_jobs, :handler, :mediumtext
    end
  end
end
