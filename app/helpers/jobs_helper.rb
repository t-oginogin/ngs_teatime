module JobsHelper
  def schedulable( job )
    job.status == 'created' || job.status == 'canceled'
  end

  def cancelable( job )
    job.status == 'scheduled' || job.status == 'doing'
  end

  def editable( job )
    job.status == 'created' || job.status == 'canceled' || job.status == 'error'
  end

  def deletable( job )
    !(job.status == 'scheduled' || job.status == 'doing' || job.status == 'canceling')
  end
end
