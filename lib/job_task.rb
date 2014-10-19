class JobTask
  class << self
    def execute
      check_done
      execute_job
    end

    private

    def check_done
      jobs = Job.where("jobs.status = 'doing'")
      (jobs || []).each do |job|
        job.be_done if job.done?
      end
    end

    def execute_job
      return if Job.where("jobs.status = 'doing'").any?

      job_ids = Job.where("jobs.status = 'scheduled'").pluck(:id)
      job_queue = JobQueue.where(job_id: job_ids).first

      # execute linux command
      if job_queue && job_queue.job
        job_queue.job.be_doing

        begin
          command = job_queue.job.command
          raise 'Job command was not found.' unless command
          IO.popen("#{job_queue.job.command}"){|ngs_io|
            job_queue.command_pid = ngs_io.pid
            job_queue.save!
          }
        rescue => e
          puts e.message
          job_queue.job.error_occurred and return
        end
      end
    end
  end
end
