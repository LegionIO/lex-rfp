# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Analytics::Client do
  subject(:client) { described_class.new }

  it 'includes Metrics runner' do
    expect(client).to respond_to(:record_proposal)
    expect(client).to respond_to(:record_outcome)
    expect(client).to respond_to(:summary)
  end

  it 'includes WinRates runner' do
    expect(client).to respond_to(:overall_win_rate)
    expect(client).to respond_to(:win_rate_by_source)
    expect(client).to respond_to(:trend)
  end

  it 'includes Quality runner' do
    expect(client).to respond_to(:score_response)
    expect(client).to respond_to(:score_proposal)
    expect(client).to respond_to(:quality_report)
  end
end
