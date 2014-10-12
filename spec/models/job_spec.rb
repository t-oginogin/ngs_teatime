require 'rails_helper'

RSpec.describe Job, :type => :model do

  describe '#schedule' do
    before do
      job = Job.new
      job.tool = 'bwa'
      job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.save!
      @job_id = job.id
    end

    context 'with valid job_id' do
      before do
        @isSuccess = Job.schedule @job_id
        @job = Job.first
      end

      it 'return true' do
        expect(@isSuccess).to eq true
      end

      it "change status to be 'scheduled'" do
        expect(@job.status).to eq 'scheduled'
      end

      it 'create JobQueue with job_id' do
        expect(@job.job_queue.job_id).to eq @job.id
      end
    end

    context 'with invalid data' do
      before do
        job = Job.first
        job.tool = nil
        job.save!(validate: false)
        @isSuccess = Job.schedule @job_id
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not create JobQueue' do
        expect(JobQueue.all.count).to eq 0
      end
    end

    context 'with not found Job' do
      before do
        @isSuccess = Job.schedule 0
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not create JobQueue' do
        expect(JobQueue.all.count).to eq 0
      end
    end
  end

  describe '#be_doing' do
    before do
      job = Job.new
      job.tool = 'bwa'
      job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.save!
      @job_id = job.id
    end

    context 'with valid data' do
      before do
        Job.schedule @job_id
        @isSuccess = Job.be_doing @job_id
        @job = Job.first
      end

      it 'return true' do
        expect(@isSuccess).to eq true
      end

      it "change status to be 'doing'" do
        expect(@job.status).to eq 'doing'
      end

      it 'do not create or delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end

    context 'with invalid data' do
      before do
        Job.schedule @job_id
        job = Job.first
        job.tool = nil
        job.save!(validate: false)
        @isSuccess = Job.be_doing @job_id
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not create or delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end

    context 'with not found Job' do
      before do
        Job.schedule @job_id
        @isSuccess = Job.be_doing 0
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not create or delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end
  end

  describe '#cancel' do
    before do
      job = Job.new
      job.tool = 'bwa'
      job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.save!
      @job_id = job.id
    end

    context 'with valid data' do
      before do
        JobQueue.create!(job_id: @job_id+1)
        Job.schedule @job_id
        @isSuccess = Job.cancel @job_id
        @job = Job.first
      end

      it 'return true' do
        expect(@isSuccess).to eq true
      end

      it "change status to be 'canceled'" do
        expect(@job.status).to eq 'canceled'
      end

      it 'delete JobQueue with job_id' do
        expect(Job.all.count).to eq 1
        expect(@job.job_queue).to be_nil 
      end
    end

    context 'with invalid data' do
      before do
        Job.schedule @job_id
        job = Job.first
        job.tool = nil
        job.save!(validate: false)
        @isSuccess = Job.cancel @job_id
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end

    context 'with not found Job' do
      before do
        Job.schedule @job_id
        @isSuccess = Job.cancel 0
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end
  end

  describe '#be_done' do
    before do
      job = Job.new
      job.tool = 'bwa'
      job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.save!
      @job_id = job.id
    end

    context 'with valid data' do
      before do
        JobQueue.create!(job_id: @job_id+1)
        Job.schedule @job_id
        @isSuccess = Job.be_done @job_id
        @job = Job.first
      end

      it 'return true' do
        expect(@isSuccess).to eq true
      end

      it "change status to be 'done'" do
        expect(@job.status).to eq 'done'
      end

      it 'delete JobQueue with job_id' do
        expect(Job.all.count).to eq 1
        expect(@job.job_queue).to be_nil
      end
    end

    context 'with invalid data' do
      before do
        Job.schedule @job_id
        job = Job.first
        job.tool = nil
        job.save!(validate: false)
        @isSuccess = Job.be_done @job_id
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end

    context 'with not found Job' do
      before do
        Job.schedule @job_id
        @isSuccess = Job.be_done 0
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end
  end

  describe '#error_occurred' do
    before do
      job = Job.new
      job.tool = 'bwa'
      job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      job.save!
      @job_id = job.id
    end

    context 'with valid data' do
      before do
        JobQueue.create!(job_id: @job_id+1)
        Job.schedule @job_id
        @isSuccess = Job.error_occurred @job_id
        @job = Job.first
      end

      it 'return true' do
        expect(@isSuccess).to eq true
      end

      it "change status to be 'error'" do
        expect(@job.status).to eq 'error'
      end

      it 'delete JobQueue with job_id' do
        expect(Job.all.count).to eq 1
        expect(@job.job_queue).to be_nil
      end
    end

    context 'with invalid data' do
      before do
        Job.schedule @job_id
        job = Job.first
        job.tool = nil
        job.save!(validate: false)
        @isSuccess = Job.error_occurred @job_id
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end

    context 'with not found Job' do
      before do
        Job.schedule @job_id
        @isSuccess = Job.error_occurred 0
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not delete JobQueue' do
        expect(Job.all.count).to eq 1
      end
    end
  end

  describe '#update_with_status' do
    before do
      @job = Job.new
      @job.tool = 'bwa'
      @job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.status = 'canceled'
      @job.save!
    end

    context 'with valid params' do
      it "change status to be 'created'" do
        params = {tool: @job.tool, target_file_1: @job.target_file_1, reference_file_1: @job.reference_file_1}

        @job.update_with_status params

        expect(@job.status).to eq 'created'
      end
    end

    context 'with invalid params' do
      it 'do not change status' do
        params = {tool: nil, target_file_1: nil, reference_file_1: nil}

        @job.update_with_status params

        expect(@job.status).to eq 'canceled'
      end
    end
  end
end
