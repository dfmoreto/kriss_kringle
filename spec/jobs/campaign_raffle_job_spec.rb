require "rails_helper"

describe CampaignRaffleJob do
  include ActiveJob::TestHelper

  before do
    @campaign = create(:campaign)
    @job = described_class.new(@campaign)
  end

  it "is in :emails queue" do
    expect(CampaignRaffleJob.new.queue_name).to eq "emails"
  end

  it "performs the job" do
    expect {
      CampaignRaffleJob.perform_later @campaign
    }.to have_enqueued_job
  end

  it "calls :error CampaignMailer when RaffleService returns false" do
    allow_any_instance_of(RaffleService).to receive(:call).and_return(false)
    delivery = double
    allow(delivery).to receive(:deliver_now).with(no_args)
    expect(CampaignMailer).to receive(:error).with(@campaign).and_return(delivery).once
    @job.perform(@campaign)
  end

  it "calls :raffle CampaignMailer when RaffleService returns content" do
    allow_any_instance_of(RaffleService).to receive(:call).and_return(josh: :sophya, sophya: :mike, mike: :leo)
    delivery = double
    allow(delivery).to receive(:deliver_now).with(no_args)
    expect(CampaignMailer).to receive(:raffle).and_return(delivery).exactly(3).times
    @job.perform(@campaign)
  end
end
