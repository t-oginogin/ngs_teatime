class AddCommandPidToJobQueue < ActiveRecord::Migration
  def change
    add_column :job_queues, :command_pid, :integer
  end
end
