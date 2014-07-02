class ChangeHandlerToMediumTextOnDelayedJobs < ActiveRecord::Migration
  def change
    change_column :delayed_jobs, :handler, :mediumtext
  end
end
