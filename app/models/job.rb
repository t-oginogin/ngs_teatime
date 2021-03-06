class Job < ActiveRecord::Base
  after_destroy :delete_work_dir

  mount_uploader :target_file_1, FastqUploader
  mount_uploader :target_file_2, FastqUploader

  has_one :job_queue

  validates_presence_of :tool
  validates_presence_of :target_file_1
  validates_presence_of :status

  STATUS = {'created' => I18n.t('messages.status.created'),
            'scheduled' => I18n.t('messages.status.scheduled'),
            'doing' => I18n.t('messages.status.doing'),
            'canceling' => I18n.t('messages.status.canceling'),
            'canceled' => I18n.t('messages.status.canceled'),
            'error' => I18n.t('messages.status.error'),
            'done' => I18n.t('messages.status.done')}

  def schedulable?
    self.status == 'created' || self.status == 'canceled'
  end

  def cancelable?
    self.status == 'scheduled' || self.status == 'doing'
  end

  def editable?
    self.status == 'created' || self.status == 'canceled' || self.status == 'error'
  end

  def deletable?
    !(self.status == 'scheduled' || self.status == 'doing' || self.status == 'canceling')
  end

  def schedule
    return false unless schedulable?

    Job.transaction do
      self.create_job_queue
      self.status = 'scheduled'
      self.started_at = nil
      self.finished_at = nil
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
      self.started_at = Time.current
      self.finished_at = nil
      self.save!
    end
      true
    rescue => e
      logger.error(I18n.t('messages.doing_job_failed'))
      logger.error(e.message)
      false
  end

  def cancel
    return false unless cancelable?

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
      self.job_queue.try(:destroy!)
      self.job_queue = nil
      self.status = 'canceled'
      self.finished_at = Time.current
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
      self.job_queue.try(:destroy!)
      self.job_queue = nil
      self.status = 'done'
      self.finished_at = Time.current
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
      self.job_queue.try(:destroy!)
      self.job_queue = nil
      self.status = 'error'
      self.finished_at = Time.current
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

  def script
    return nil if command.blank?

    script_path = "#{work_path}/job_command_#{self.id}.sh"

    File.open(script_path, "w", 0755) do |f|
      f.write command
    end

    # execute background and return pid
    "#{script_path} > #{work_path}/job_command_#{self.id}.log 2>&1 & echo $!"
  end

  def done?
    pid = self.job_queue.try(:command_pid)
    return true unless pid

    begin
      return false if `ps #{pid}` =~ /#{pid}/
    rescue => e
      Rails.logger.error e.message
    end
    true
  end

  def result_files
    files = Dir.glob("#{Rails.root}/#{work_path}/*")
    files.select{|f| !(f =~ /job_command_[\d]+.sh/)}.map{|f| File.basename f}
  end

  def result_file(file_name)
    "#{Rails.root}/#{work_path}/#{file_name}"
  end

  private

  def vicuna_command
    create_work_dir
    config_base_file = "#{Rails.root}/config/vicuna_config.txt"
    config_file = "#{work_path}/job_#{self.id}_#{tool}_config.txt"
    tool_log = "#{work_path}/job_#{self.id}_#{tool}.log"

    File.open(config_file, "w", 0644) do |f_out|
      File.open(config_base_file, "r") do |f_in|
        f_in.each_line do |line|
          replaced_line = line.gsub(/\#\{input_directory\}/, "#{Rails.root}/#{work_path}/")
          replaced_line = replaced_line.gsub(/\#\{output_directory\}/, "#{Rails.root}/#{work_path}/")
          f_out.write replaced_line
        end
      end
    end

    return nil unless FileTest.exist?(config_file)
    FileUtils.ln_sf(self.target_file_1.path, "#{work_path}/#{self.target_file_1.file.filename}")
    FileUtils.ln_sf(self.target_file_2.path, "#{work_path}/#{self.target_file_2.file.filename}")

    command_string = <<-"EOS"
    OMP_NUM_THREADS=#{Settings.cpu_core_count} vicuna-omp-v1.0 #{config_file} > #{tool_log} 2>&1;
    EOS

    command_string
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
    index_file = "#{indexes_path}#{self.reference_genome}"
    tool_log = "#{work_path}/job_#{self.id}_#{tool}.log"
    un_conc_result = "#{work_path}/job_#{self.id}_un.fastq"
    al_conc_result = "#{work_path}/job_#{self.id}_al.fastq"
    un_conc_result_1 = "#{work_path}/job_#{self.id}_un.1.fastq"
    un_conc_result_2 = "#{work_path}/job_#{self.id}_un.2.fastq"
    al_conc_result_1 = "#{work_path}/job_#{self.id}_al.1.fastq"
    al_conc_result_2 = "#{work_path}/job_#{self.id}_al.2.fastq"
    un_conc_trimmed_result_1 = "#{work_path}/job_#{self.id}_un_trim_1.fastq"
    un_conc_trimmed_result_2 = "#{work_path}/job_#{self.id}_un_trim_2.fastq"
    al_conc_trimmed_result_1 = "#{work_path}/job_#{self.id}_al_trim_1.fastq"
    al_conc_trimmed_result_2 = "#{work_path}/job_#{self.id}_al_trim_2.fastq"

    command_string = <<-"EOS"
    bowtie2 -p #{Settings.cpu_core_count} --un-conc #{un_conc_result} --al-conc #{al_conc_result} -x #{index_file} -1 #{self.target_file_1.path} -2 #{self.target_file_2.path} 1>/dev/null 2>#{tool_log};
    fastq_quality_filter -Q33 -q 20 -p 80 -i #{un_conc_result_1} | fastq_quality_trimmer -Q33 -t 20 -l 10 -o #{un_conc_trimmed_result_1};
    fastq_quality_filter -Q33 -q 20 -p 80 -i #{un_conc_result_2} | fastq_quality_trimmer -Q33 -t 20 -l 10 -o #{un_conc_trimmed_result_2};
    fastq_quality_filter -Q33 -q 20 -p 80 -i #{al_conc_result_1} | fastq_quality_trimmer -Q33 -t 20 -l 10 -o #{al_conc_trimmed_result_1};
    fastq_quality_filter -Q33 -q 20 -p 80 -i #{al_conc_result_2} | fastq_quality_trimmer -Q33 -t 20 -l 10 -o #{al_conc_trimmed_result_2};
    EOS

    command_string
  end

  def work_path
    "#{Settings.job.work_path}/#{self.id}"
  end

  def cmp_path
    "#{work_path}/cmp"
  end

  def create_work_dir
    FileUtils.mkdir_p(work_path) unless FileTest.exist?(work_path)
  end

  def delete_work_dir
    FileUtils.rm_rf(work_path) if FileTest.exist?(work_path)
  end

  def indexes_path
    "#{Settings.job.indexes_path}/"
  end
end
