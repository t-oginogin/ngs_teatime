class Job < ActiveRecord::Base
  validates_presence_of :tool
  validates_presence_of :target_file_1
  validates_presence_of :reference_file_1
end
