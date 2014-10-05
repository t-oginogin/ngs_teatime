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

  class << self
    def schedule( job_id )
      Job.transaction do
        JobQueue.new(job_id: job_id).save!
        job = Job.find job_id
        job.status = 'scheduled'
        job.save!
      end
        true
      rescue => e
        logger.error(I18n.t('messages.schedule_job_failed'))
        logger.error(e.message)
        false
    end

    def be_doing( job_id )
      Job.transaction do
        job = Job.find job_id
        job.status = 'doing'
        job.save!
      end
        true
      rescue => e
        logger.error(I18n.t('messages.doing_job_failed'))
        logger.error(e.message)
        false
    end

    def cancel( job_id )
      Job.transaction do
        JobQueue.find_by(job_id: job_id).destroy!
        job = Job.find job_id
        job.status = 'canceled'
        job.save!
      end
        true
      rescue => e
        logger.error(I18n.t('messages.cancel_job_failed'))
        logger.error(e.message)
        false
    end

    def be_done( job_id )
      Job.transaction do
        JobQueue.find_by(job_id: job_id).destroy!
        job = Job.find job_id
        job.status = 'done'
        job.save!
      end
        true
      rescue => e
        logger.error(I18n.t('messages.done_job_failed'))
        logger.error(e.message)
        false
    end

    def error_occurred( job_id )
      Job.transaction do
        JobQueue.find_by(job_id: job_id).destroy!
        job = Job.find job_id
        job.status = 'error'
        job.save!
      end
        true
      rescue => e
        logger.error(I18n.t('messages.error_occurred_job_failed'))
        logger.error(e.message)
        false
    end
  end

  def update_with_status( params )
    if self.update params
      self.status = 'created'
      self.save!
    end
  end
end
