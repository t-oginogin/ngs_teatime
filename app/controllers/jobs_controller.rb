class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :schedule, :cancel]

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.all
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
  end

  # GET /jobs/new
  def new
    @job = Job.new
  end

  # GET /jobs/1/edit
  def edit
  end

  # GET /jobs/1/schedule
  def schedule
    respond_to do |format|
      if @job.schedule
        format.html { redirect_to jobs_url, notice: t('messages.scheduled_job') }
      else
        format.html { redirect_to jobs_url, alert: t('messages.schedule_job_failed') }
      end
    end
  end

  # GET /jobs/1/cancel
  def cancel
    respond_to do |format|
      if @job.cancel
        format.html { redirect_to jobs_url, notice: t('messages.canceled_job') }
      else
        format.html { redirect_to jobs_url, alert: t('messages.cancel_job_failed') }
      end
    end
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: t('messages.created_job') }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update_with_status(job_params)
        format.html { redirect_to @job, notice: t('messages.updated_job') }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: t('messages.deleted_job') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:tool, :comment,
                                  :target_file_1, :target_file_1_cache, :remove_target_file_1,
                                  :target_file_2, :target_file_2_cache, :remove_target_file_2,
                                  :reference_file_1, :reference_file_1_cache, :remove_reference_file_1,
                                  :reference_file_2, :reference_file_2_cache, :remove_reference_file_2)
    end
end
