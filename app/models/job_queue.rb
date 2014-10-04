class JobQueue < ActiveRecord::Base
  has_one :job
  validates_presence_of :job_id
end
