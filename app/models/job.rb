class Job < ActiveRecord::Base
  mount_uploader :target_file_1, FastqUploader
  mount_uploader :target_file_2, FastqUploader
  mount_uploader :reference_file_1, FastqUploader
  mount_uploader :reference_file_2, FastqUploader

  validates_presence_of :tool
  validates_presence_of :target_file_1
  validates_presence_of :reference_file_1
  validates_presence_of :status

  STATUS = {'created' => I18n.t('messages.status.created'),
            'scheduled' => I18n.t('messages.status.scheduled'),
            'doing' => I18n.t('messages.status.doing'),
            'canceled' => I18n.t('messages.status.canceled'),
            'error' => I18n.t('messages.status.error'),
            'done' => I18n.t('messages.status.done')}
end
