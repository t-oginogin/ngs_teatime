class JobTask
  class << self
    def execute
      check_done
      check_cancel
      execute_job
    end

    private

    def check_done
      jobs = Job.where("jobs.status = 'doing'")
      (jobs || []).each do |job|
        job.be_done if job.done?
      end
    end

    def check_cancel
      jobs = Job.where("jobs.status = 'canceling'")
      (jobs || []).each do |job|
        IO.popen("kill -TERM #{job.job_queue.command_pid}")
        job.be_canceled
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

          IO.popen(command) {}
          IO.popen("ps aux | grep -E \"#{job_queue.job.tool}\.\*job_#{job_queue.job.id}\"") do |pipe|
            pipe.readlines.each do |line|
              job_queue.command_pid = line.split[1] if line =~ /^(?!.*grep -E).*$/
            end
          end

          job_queue.save!
        rescue => e
          Rails.logger.error e.message
          job_queue.job.error_occurred and return
        end
      end
    end
  end
end
