class JobQueue < ActiveRecord::Base
  belongs_to :job
  validates_presence_of :job_id
end
