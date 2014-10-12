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
end
