module JobsHelper
  def schedulable( job )
    job.schedulable?
  end

  def cancelable( job )
    job.cancelable?
  end

  def editable( job )
    job.editable?
  end

  def deletable( job )
    job.deletable?
  end
end
