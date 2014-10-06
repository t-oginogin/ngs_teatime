class JobTask
  def self.execute
    return if Job.where("jobs.status = 'doing'").any?

    job_ids = Job.where("jobs.status = 'scheduled'").pluck(:id)
    job_queue = JobQueue.where(job_id: job_ids).first

    if job_queue && job_queue.job
      job_queue.job.status = 'doing'
      job_queue.job.save

      # ToDo: execute linux command
      
      job_queue.job.status = 'done'
      job_queue.job.save
    end
  end
end
