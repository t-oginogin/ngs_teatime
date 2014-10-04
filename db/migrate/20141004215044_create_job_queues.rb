class CreateJobQueues < ActiveRecord::Migration
  def change
    create_table :job_queues do |t|
      t.integer :job_id, unique: :true, null: :false

      t.timestamps
    end
  end
end
