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
            'canceling' => I18n.t('messages.status.canceling'),
            'canceled' => I18n.t('messages.status.canceled'),
            'error' => I18n.t('messages.status.error'),
            'done' => I18n.t('messages.status.done')}

  def schedule
    Job.transaction do
      self.create_job_queue
      self.status = 'scheduled'
      self.save!
    end
      true
    rescue => e
      logger.error(I18n.t('messages.schedule_job_failed'))
      logger.error(e.message)
      false
  end

  def be_doing
    Job.transaction do
      self.status = 'doing'
      self.save!
    end
      true
    rescue => e
      logger.error(I18n.t('messages.doing_job_failed'))
      logger.error(e.message)
      false
  end

  def cancel
    Job.transaction do
      self.status = 'canceling'
      self.save!
    end
      true
    rescue => e
      logger.error(I18n.t('messages.canceling_job_failed'))
      logger.error(e.message)
      false
  end

  def be_canceled
    Job.transaction do
      self.job_queue.destroy!
      self.job_queue = nil
      self.status = 'canceled'
      self.save!
    end
      true
    rescue => e
      logger.error(I18n.t('messages.cancel_job_failed'))
      logger.error(e.message)
      false
  end

  def be_done
    Job.transaction do
      self.job_queue.destroy!
      self.job_queue = nil
      self.status = 'done'
      self.save!
    end
      true
    rescue => e
      logger.error(I18n.t('messages.done_job_failed'))
      logger.error(e.message)
      false
  end

  def error_occurred
    Job.transaction do
      self.job_queue.destroy!
      self.job_queue = nil
      self.status = 'error'
      self.save!
    end
      true
    rescue => e
      logger.error(I18n.t('messages.error_occurred_job_failed'))
      logger.error(e.message)
      false
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

  def done?
    return true if FileTest.exist?(cmp_path)
    false
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
    create_work_dir

    command = <<-"EOS"
    exec bowtie2 -p 2 --un-conc #{work_path}/job_#{self.id}_un.fastq --al-conc #{work_path}/job_#{self.id}_al.fastq -x #{File.dirname(self.reference_file_1.path)} -1 #{self.target_file_1.path} -2 #{self.target_file_2.path} > /dev/null 2> #{work_path}/job_#{self.id}.log
    EOS
    command
  end

  def work_path
    work_path = "tmp/job_work/#{Rails.env}/#{self.id}"
  end

  def cmp_path
    "#{work_path}/cmp"
  end

  def create_work_dir
    FileUtils.mkdir_p(work_path) unless FileTest.exist?(work_path)
  end
end
