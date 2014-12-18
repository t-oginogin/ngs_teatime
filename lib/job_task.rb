class JobTask
  class << self
    def execute
      check_done
      check_cancel
      execute_job
    end

    private

    def system_command(command)
      `#{command}`
    end

    def check_done
      jobs = Job.where("jobs.status = 'doing'")
      (jobs || []).each do |job|
        job.be_done if job.done?
      end
    end

    def check_cancel
      jobs = Job.where("jobs.status = 'canceling'")
      (jobs || []).each do |job|
        job.be_canceled and next if job.job_queue.command_pid.blank?

        command = "ps -p #{job.job_queue.command_pid} -o \"pgid\""
        pgid = system_command(command).lines.to_a.last.lstrip.chomp
        if pgid =~ /[0-9]/
          system_command "kill -TERM -#{pgid}"
        else
          Rails.logger.error 'Process was not found' and next
        end
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

          fork do
            Process.setsid
            pid = system_command(job_queue.job.command_to_script command).lstrip.chomp
            if pid =~ /[0-9]/
              job_queue.command_pid = pid
              job_queue.save!
            else
              Rails.logger.error 'command has not pid'
            end
          end
        rescue => e
          Rails.logger.error e.message
          job_queue.job.error_occurred and return
        end
      end
    end
  end
end
