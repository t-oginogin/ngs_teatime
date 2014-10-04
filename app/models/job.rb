class Job < ActiveRecord::Base
  mount_uploader :target_file_1, FastqUploader
  mount_uploader :target_file_2, FastqUploader
  mount_uploader :reference_file_1, FastqUploader
  mount_uploader :reference_file_2, FastqUploader

  validates_presence_of :tool
  validates_presence_of :target_file_1
  validates_presence_of :reference_file_1
end
