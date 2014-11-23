class RemoveReferenceFileFromJob < ActiveRecord::Migration
  def change
    remove_column :jobs, :reference_file_1
    remove_column :jobs, :reference_file_2
  end
end
