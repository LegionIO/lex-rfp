# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Analytics::Runners::Metrics do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Analytics::Runners::Metrics } }
  let(:instance) { test_class.new }

  describe '#record_proposal' do
    it 'creates a proposal metric record' do
      result = instance.record_proposal(proposal_id: 'prop-1', rfp_source: 'employer-group', sections: 5, word_count: 3000)
      expect(result[:result][:proposal_id]).to eq('prop-1')
      expect(result[:result][:sections]).to eq(5)
    end
  end

  describe '#record_outcome' do
    it 'records a valid outcome' do
      result = instance.record_outcome(proposal_id: 'prop-1', outcome: 'won', revenue: 500_000)
      expect(result[:result][:outcome]).to eq(:won)
      expect(result[:result][:revenue]).to eq(500_000)
    end

    it 'rejects invalid outcomes' do
      result = instance.record_outcome(proposal_id: 'prop-1', outcome: 'invalid')
      expect(result[:error]).to include('Invalid outcome')
    end
  end

  describe '#summary' do
    it 'calculates summary statistics' do
      proposals = [
        { outcome: :won, revenue: 100_000 },
        { outcome: :won, revenue: 200_000 },
        { outcome: :lost },
        { outcome: :pending }
      ]
      result = instance.summary(proposals: proposals)
      stats = result[:result]
      expect(stats[:total_proposals]).to eq(4)
      expect(stats[:won]).to eq(2)
      expect(stats[:lost]).to eq(1)
      expect(stats[:win_rate]).to be_within(0.01).of(0.6667)
      expect(stats[:total_revenue]).to eq(300_000)
    end

    it 'handles empty proposals' do
      result = instance.summary(proposals: [])
      expect(result[:result][:win_rate]).to eq(0.0)
    end
  end
end
