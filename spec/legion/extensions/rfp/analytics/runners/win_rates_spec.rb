# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Analytics::Runners::WinRates do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Analytics::Runners::WinRates } }
  let(:instance) { test_class.new }

  let(:proposals) do
    [
      { outcome: :won, rfp_source: 'employer', template: :healthcare, submitted_at: '2026-01-15' },
      { outcome: :lost, rfp_source: 'employer', template: :healthcare, submitted_at: '2026-01-20' },
      { outcome: :won, rfp_source: 'government', template: :government, submitted_at: '2026-02-10' },
      { outcome: :won, rfp_source: 'government', template: :government, submitted_at: '2026-03-05' }
    ]
  end

  describe '#overall_win_rate' do
    it 'calculates overall win rate' do
      result = instance.overall_win_rate(proposals: proposals)
      expect(result[:result]).to eq(0.75)
      expect(result[:won]).to eq(3)
      expect(result[:decided]).to eq(4)
    end

    it 'returns 0 for no decided proposals' do
      result = instance.overall_win_rate(proposals: [{ outcome: :pending }])
      expect(result[:result]).to eq(0.0)
    end
  end

  describe '#win_rate_by_source' do
    it 'groups win rates by source' do
      result = instance.win_rate_by_source(proposals: proposals)
      expect(result[:result]['employer'][:rate]).to eq(0.5)
      expect(result[:result]['government'][:rate]).to eq(1.0)
    end
  end

  describe '#win_rate_by_template' do
    it 'groups win rates by template' do
      result = instance.win_rate_by_template(proposals: proposals)
      expect(result[:result][:healthcare][:rate]).to eq(0.5)
      expect(result[:result][:government][:rate]).to eq(1.0)
    end
  end

  describe '#trend' do
    it 'returns monthly trend data' do
      result = instance.trend(proposals: proposals, period: :monthly)
      expect(result[:result].keys).to include('2026-01', '2026-02')
      expect(result[:period]).to eq(:monthly)
    end

    it 'returns quarterly trend data' do
      result = instance.trend(proposals: proposals, period: :quarterly)
      expect(result[:result].keys).to include('2026-Q1')
    end
  end
end
