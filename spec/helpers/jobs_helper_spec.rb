require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the JobsHelper. For example:
#
# describe JobsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe JobsHelper, :type => :helper do
  before do
    @job = Job.new
  end

  describe '#schedulable' do
    context "when status is 'created'" do
     it 'returns true' do
       @job.status = 'created'
       expect(helper.schedulable @job).to be true
     end
    end

    context "when status is 'scheduled'" do
     it 'returns false' do
       @job.status = 'scheduled'
       expect(helper.schedulable @job).to be false
     end
    end

    context "when status is 'doing'" do
     it 'returns false' do
       @job.status = 'doing'
       expect(helper.schedulable @job).to be false
     end
    end

    context "when status is 'canceling'" do
     it 'returns false' do
       @job.status = 'canceling'
       expect(helper.schedulable @job).to be false
     end
    end

    context "when status is 'canceled'" do
     it 'returns true' do
       @job.status = 'canceled'
       expect(helper.schedulable @job).to be true
     end
    end

    context "when status is 'error'" do
     it 'returns false' do
       @job.status = 'error'
       expect(helper.schedulable @job).to be false
     end
    end
  end

  describe '#cancelable' do
    context "when status is 'created'" do
     it 'returns false' do
       @job.status = 'created'
       expect(helper.cancelable @job).to be false
     end
    end

    context "when status is 'scheduled'" do
     it 'returns true' do
       @job.status = 'scheduled'
       expect(helper.cancelable @job).to be true
     end
    end

    context "when status is 'doing'" do
     it 'returns true' do
       @job.status = 'doing'
       expect(helper.cancelable @job).to be true
     end
    end

    context "when status is 'canceling'" do
     it 'returns false' do
       @job.status = 'canceling'
       expect(helper.cancelable @job).to be false
     end
    end

    context "when status is 'canceled'" do
     it 'returns false' do
       @job.status = 'canceled'
       expect(helper.cancelable @job).to be false
     end
    end

    context "when status is 'error'" do
     it 'returns false' do
       @job.status = 'error'
       expect(helper.cancelable @job).to be false
     end
    end
  end

  describe '#editable' do
    context "when status is 'created'" do
     it 'returns true' do
       @job.status = 'created'
       expect(helper.editable @job).to be true
     end
    end

    context "when status is 'scheduled'" do
     it 'returns false' do
       @job.status = 'scheduled'
       expect(helper.editable @job).to be false
     end
    end

    context "when status is 'doing'" do
     it 'returns false' do
       @job.status = 'doing'
       expect(helper.editable @job).to be false
     end
    end

    context "when status is 'canceling'" do
     it 'returns false' do
       @job.status = 'canceling'
       expect(helper.editable @job).to be false
     end
    end

    context "when status is 'canceled'" do
     it 'returns true' do
       @job.status = 'canceled'
       expect(helper.editable @job).to be true
     end
    end

    context "when status is 'error'" do
     it 'returns true' do
       @job.status = 'error'
       expect(helper.editable @job).to be true
     end
    end
  end

  describe '#deletable' do
    context "when status is 'created'" do
     it 'returns true' do
       @job.status = 'created'
       expect(helper.deletable @job).to be true
     end
    end

    context "when status is 'scheduled'" do
     it 'returns false' do
       @job.status = 'scheduled'
       expect(helper.deletable @job).to be false
     end
    end

    context "when status is 'doing'" do
     it 'returns false' do
       @job.status = 'doing'
       expect(helper.deletable @job).to be false
     end
    end

    context "when status is 'canceling'" do
     it 'returns false' do
       @job.status = 'canceling'
       expect(helper.deletable @job).to be false
     end
    end

    context "when status is 'canceled'" do
     it 'returns true' do
       @job.status = 'canceled'
       expect(helper.deletable @job).to be true
     end
    end

    context "when status is 'error'" do
     it 'returns true' do
       @job.status = 'error'
       expect(helper.deletable @job).to be true
     end
    end
  end
end
