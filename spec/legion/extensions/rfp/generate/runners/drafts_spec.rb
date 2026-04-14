# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Generate::Runners::Drafts do
  let(:test_class) do
    Class.new do
      include Legion::Extensions::Rfp::Generate::Runners::Sections
      include Legion::Extensions::Rfp::Generate::Runners::Drafts
    end
  end
  let(:instance) { test_class.new }

  describe '#generate_response' do
    it 'returns a response hash with the question' do
      result = instance.generate_response(question: 'Describe your network coverage')
      expect(result[:question]).to eq('Describe your network coverage')
      expect(result[:result]).to be_a(String)
    end

    it 'includes context count' do
      result = instance.generate_response(question: 'Test question')
      expect(result[:context_used]).to eq(0)
    end
  end

  describe '#regenerate' do
    it 'returns a revision response' do
      result = instance.regenerate(
        question:        'Coverage question',
        previous_answer: 'Original answer',
        feedback:        'Needs more detail'
      )
      expect(result[:revision]).to be true
      expect(result[:question]).to eq('Coverage question')
    end
  end

  describe '#generate_full_draft' do
    it 'generates responses for parsed questions' do
      rfp_text = "SECTION ONE\n1. Describe your approach.\n2. What is your timeline?"
      result = instance.generate_full_draft(rfp_text: rfp_text)
      expect(result[:sections]).to eq(2)
      expect(result[:result]).to be_a(String)
    end
  end
end
