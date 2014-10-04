class ChangeJobStatusDefault < ActiveRecord::Migration
  change_column_default :jobs, :status, 'created'
end
