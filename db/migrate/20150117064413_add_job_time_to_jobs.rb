class AddJobTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :started_at, :datetime, null: true
    add_column :jobs, :finished_at, :datetime, null: true
  end
end
