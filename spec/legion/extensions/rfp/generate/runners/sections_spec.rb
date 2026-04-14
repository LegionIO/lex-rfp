# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Generate::Runners::Sections do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Generate::Runners::Sections } }
  let(:instance) { test_class.new }

  describe '#generate_section_response' do
    it 'returns a section response' do
      result = instance.generate_section_response(question: 'Describe your quality measures', section: 'Quality')
      expect(result[:section]).to eq('Quality')
      expect(result[:question]).to eq('Describe your quality measures')
      expect(result[:result]).to be_a(String)
    end
  end

  describe '#generate_executive_summary' do
    it 'returns an executive summary' do
      result = instance.generate_executive_summary(rfp_text: 'Healthcare RFP for large employer group')
      expect(result[:type]).to eq(:executive_summary)
      expect(result[:result]).to be_a(String)
    end
  end

  describe '#generate_compliance_matrix' do
    it 'returns a compliance matrix' do
      requirements = [{ text: 'Must support HIPAA' }, { text: 'Must provide 24/7 support' }]
      result = instance.generate_compliance_matrix(requirements: requirements)
      expect(result[:type]).to eq(:compliance_matrix)
      expect(result[:requirements_count]).to eq(2)
    end
  end
end
