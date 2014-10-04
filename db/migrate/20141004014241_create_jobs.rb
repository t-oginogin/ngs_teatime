class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :tool
      t.string :target_file_1
      t.string :target_file_2
      t.string :reference_file_1
      t.string :reference_file_2
      t.string :comment
      t.string :status

      t.timestamps
    end
  end
end
