# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Analytics::Runners::Quality do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Analytics::Runners::Quality } }
  let(:instance) { test_class.new }

  describe '#score_response' do
    it 'scores a response across all dimensions' do
      text = 'Our comprehensive healthcare delivery network provides 24/7 support with HIPAA-compliant systems. ' \
             'We serve over 500 employer groups nationally with a proven track record of quality outcomes. ' \
             'Our approach includes dedicated account management, real-time reporting, and continuous improvement.'
      result = instance.score_response(
        response_text: text,
        question:      'Describe your healthcare delivery approach',
        requirements:  [{ text: 'Must provide 24/7 support' }]
      )
      scores = result[:result][:scores]
      expect(scores).to have_key(:completeness)
      expect(scores).to have_key(:relevance)
      expect(scores).to have_key(:clarity)
      expect(scores).to have_key(:compliance)
      expect(result[:result][:overall]).to be_a(Float)
    end

    it 'returns zero for empty text' do
      result = instance.score_response(response_text: '')
      expect(result[:result][:scores][:completeness]).to eq(0.0)
    end
  end

  describe '#score_proposal' do
    it 'scores all sections of a proposal' do
      sections = [
        { name: 'summary', content: 'Our company provides excellent healthcare services to employers.', question: 'Summarize' },
        { name: 'approach', content: 'We use a data-driven approach to improve health outcomes for members.', question: 'Describe approach' }
      ]
      result = instance.score_proposal(sections: sections)
      expect(result[:result][:sections].length).to eq(2)
      expect(result[:result][:overall]).to be_a(Float)
    end

    it 'handles empty sections' do
      result = instance.score_proposal(sections: [])
      expect(result[:result][:overall]).to eq(0.0)
    end
  end

  describe '#quality_report' do
    it 'generates aggregate quality report' do
      proposals = [
        { quality: { scores: { completeness: 80.0, relevance: 70.0, clarity: 90.0, compliance: 85.0 } } },
        { quality: { scores: { completeness: 60.0, relevance: 80.0, clarity: 75.0, compliance: 90.0 } } }
      ]
      result = instance.quality_report(proposals: proposals)
      expect(result[:result][:count]).to eq(2)
      expect(result[:result][:average_scores][:completeness]).to eq(70.0)
    end

    it 'handles empty proposals' do
      result = instance.quality_report(proposals: [])
      expect(result[:result][:count]).to eq(0)
    end
  end
end
