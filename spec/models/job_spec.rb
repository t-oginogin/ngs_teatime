require 'rails_helper'

RSpec.describe Job, :type => :model do

  describe '#schedule' do
    before do
      @job = Job.new
      @job.tool = 'bwa'
      @job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.save!
    end

    context 'with valid job' do
      before do
        @isSuccess = @job.schedule
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
        @job.tool = nil
        @job.save!(validate: false)
        @isSuccess = @job.schedule
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
      @job = Job.new
      @job.tool = 'bwa'
      @job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.save!
    end

    context 'with valid data' do
      before do
        @job.schedule
        @isSuccess = @job.be_doing
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
        @job.schedule
        @job.tool = nil
        @job.save!(validate: false)
        @isSuccess = @job.be_doing
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
      @job = Job.new
      @job.tool = 'bwa'
      @job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.save!
    end

    context 'with valid data' do
      before do
        JobQueue.create!(job_id: @job.id + 1)
        @job.schedule
        @isSuccess = @job.cancel
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
        @job.schedule
        @job.tool = nil
        @job.save!(validate: false)
        @isSuccess = @job.cancel
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
      @job = Job.new
      @job.tool = 'bwa'
      @job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.save!
    end

    context 'with valid data' do
      before do
        JobQueue.create!(job_id: @job.id + 1)
        @job.schedule
        @isSuccess = @job.be_done
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
        @job.schedule
        @job.tool = nil
        @job.save!(validate: false)
        @isSuccess = @job.be_done
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
      @job = Job.new
      @job.tool = 'bwa'
      @job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.save!
    end

    context 'with valid data' do
      before do
        JobQueue.create!(job_id: @job.id + 1)
        @job.schedule
        @isSuccess = @job.error_occurred
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
        @job.schedule
        @job.tool = nil
        @job.save!(validate: false)
        @isSuccess = @job.error_occurred
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
