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

      it "change status to be 'canceling'" do
        expect(@job.status).to eq 'canceling'
      end

      it 'do not delete JobQueue with job_id' do
        expect(JobQueue.all.count).to eq 2
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
        expect(JobQueue.all.count).to eq 1
      end
    end
  end

  describe '#be_canceled' do
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
        @isSuccess = @job.be_canceled
      end

      it 'return true' do
        expect(@isSuccess).to eq true
      end

      it "change status to be 'canceled'" do
        expect(@job.status).to eq 'canceled'
      end

      it 'delete JobQueue with job_id' do
        expect(JobQueue.all.count).to eq 1
        expect(@job.job_queue).to be_nil
      end
    end

    context 'with invalid data' do
      before do
        @job.schedule
        @job.tool = nil
        @job.save!(validate: false)
        @isSuccess = @job.be_canceled
      end

      it 'return false' do
        expect(@isSuccess).to eq false
      end

      it 'do not delete JobQueue' do
        expect(JobQueue.all.count).to eq 1
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

  describe '#command' do
    before do
      @job = Job.new
      @job.tool = 'vicuna'
      @job.target_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.reference_file_1 = File.open(File.join(Rails.root, '/spec/fixtures/files/test.fastq'))
      @job.save!
      FileUtils.rm_rf("tmp/job_work/#{Rails.env}/#{@job.id}")
    end

    after do
      FileUtils.rm_rf("tmp/job_work/#{Rails.env}/#{@job.id}")
    end

    context 'with vicuna' do
      skip 'return vicuna command string' do
        @job.tool = 'vicuna'
        @job.save!
        expect(@job.command).to match /vicuna/
      end
    end

    context 'with bwa' do
      skip 'return bwa command string' do
        @job.tool = 'bwa'
        @job.save!
        expect(@job.command).to match /bwa/
      end
    end

    context 'with bwa2' do
      skip 'return bwa2 command string' do
        @job.tool = 'bwa2'
        @job.save!
        expect(@job.command).to match /bwa2/
      end
    end

    context 'with sam_tools' do
      skip 'return sam_tools command string' do
        @job.tool = 'sam_tools'
        @job.save!
        expect(@job.command).to match /sam_tools/
      end
    end

    context 'with bowtie' do
      skip 'return bowtie command string' do
        @job.tool = 'bowtie'
        @job.save!
        expect(@job.command).to match /bowtie/
      end
    end

    context 'with bowtie2' do
      it 'return bowtie2 command string' do
        @job.tool = 'bowtie2'
        @job.save!
        expect(@job.command).to match /bowtie2/
      end

      it 'created work dir' do
        @job.tool = 'bowtie2'
        @job.save!
        @job.command

        isExist = FileTest.exist?("tmp/job_work/#{Rails.env}/#{@job.id}")
        expect(isExist).to be true
      end
    end

    context 'with invalid tool' do
      it 'return nil' do
        @job.tool = ''
        @job.save!(validate: false)
        expect(@job.command).to be_nil
      end
    end

  end
end
