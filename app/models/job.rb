class Job < ActiveRecord::Base
  mount_uploader :target_file_1, FastqUploader
  mount_uploader :target_file_2, FastqUploader
  mount_uploader :reference_file_1, FastqUploader
  mount_uploader :reference_file_2, FastqUploader

  has_one :job_queue

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

  def command
    self.send "#{self.tool}_command" if self.tool.present?
  end

  private

  def vicuna_command
    logger.error "vicuna command is not supported now"
    nil
  end

  def bwa_command
    logger.error "bwa command is not supported now"
    return nil
=begin
    basename_1 = File.basename(self.target_file_1.path, File.extname(self.target_file_1.path))
    basename_2 = File.basename(self.target_file_2.path, File.extname(self.target_file_1.path))
    sai_1_path = "tmp/job_work/#{self.id}/#{basename_1}.sai"
    sai_2_path = "tmp/job_work/#{self.id}/#{basename_2}.sai"
    sam_path = "tmp/job_work/#{self.id}/#{basename_1}.sam"
    cmp_path = "tmp/job_work/#{self.id}/cmp"

    command = <<-"EOS"
    bwa index -a bwtsw #{self.reference_file_1.path}
    bwa aln -t 2 #{self.reference_file_1.path} #{self.target_file_1.path} > #{sai_1_path}
    bwa aln -t 2 #{self.reference_file_1.path} #{self.target_file_2.path} > #{sai_2_path}
    bwa sampe -P #{self.reference_file_1.path} #{sai_1_path} #{sai_2_path} #{self.target_file_1.path} #{self.target_file_2.path} -r "@RG\tID:01\tSM:s6\tPL:Illumina" > #{sam_path}
    touch #{cmp_path}
    EOS
    command
=end
  end

  def bwa2_command
    logger.error "bwa2 command is not supported now"
    nil
  end

  def sam_tools_command
    logger.error "sam_tools command is not supported now"
    return nil
=begin
    basename_1 = File.basename(self.target_file_1.path, File.extname(self.target_file_1.path))
    sam_path = "tmp/job_work/#{self.id}/#{basename_1}.sam"
    bam_path = "tmp/job_work/#{self.id}/#{basename_1}.bam"
    sorted_name = "tmp/job_work/#{self.id}/#{basename_1}_sorted"
    sorted_bam_path = "#{sorted_name}.bam"
    cmp_path = "tmp/job_work/#{self.id}/cmp"

    command = <<-"EOS"
    samtools view -bS #{sam_path} > #{bam_path}
    samtools sort #{bam_path} #{sorted_name}
    samtools index #{sorted_bam_path}
    touch #{cmp_path}
    EOS
    command
=end
  end

  def bowtie_command
    logger.error "bowtie command is not supported now"
    nil
  end

  def bowtie2_command
    logger.error "bowtie2 command is not supported now"
    return nil
=begin
    cmp_path = "tmp/job_work/#{self.id}/cmp"

    command = <<-"EOS"
    bowtie2 -p 2 --un-conc #{self.id}_un.fastq --al-conc #{self.id}_al.fastq -x #{File.dirname(self.reference_file_1.path)} -1 #{self.target_fastq_1.path} -2 #{self.target_fastq_2.path} > /dev/null 2> tmp/job_work/#{self.id}/bowtie2.log
    touch #{cmp_path}
    EOS
    command
=end
  end

  def done?
    # TODO: if 'cmp' file is exist then return true
    false
  end
end
