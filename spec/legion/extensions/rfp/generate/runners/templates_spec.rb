# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Generate::Runners::Templates do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Generate::Runners::Templates } }
  let(:instance) { test_class.new }

  describe '#list_templates' do
    it 'returns available templates' do
      result = instance.list_templates
      expect(result[:result]).to include(:standard, :government, :healthcare)
      expect(result[:count]).to eq(3)
    end
  end

  describe '#get_template' do
    it 'returns a template by name' do
      result = instance.get_template(name: 'healthcare')
      expect(result[:result][:sections]).to include(:executive_summary)
      expect(result[:name]).to eq('healthcare')
    end

    it 'returns error for unknown template' do
      result = instance.get_template(name: 'nonexistent')
      expect(result[:error]).to include('not found')
    end
  end

  describe '#apply_template' do
    it 'applies a template to RFP data' do
      result = instance.apply_template(name: 'standard', rfp_data: { executive_summary: 'Summary content' })
      expect(result[:template]).to eq('standard')
      expect(result[:sections]).to be_positive
    end

    it 'returns error for unknown template' do
      result = instance.apply_template(name: 'unknown', rfp_data: {})
      expect(result[:error]).to include('not found')
    end
  end

  describe '#suggest_template' do
    it 'suggests healthcare for medical terms' do
      result = instance.suggest_template(rfp_text: 'This RFP covers Medicare Advantage plans and HIPAA compliance')
      expect(result[:result]).to eq(:healthcare)
    end

    it 'suggests government for federal terms' do
      result = instance.suggest_template(rfp_text: 'Federal agency procurement under FAR guidelines')
      expect(result[:result]).to eq(:government)
    end

    it 'defaults to standard' do
      result = instance.suggest_template(rfp_text: 'General business proposal')
      expect(result[:result]).to eq(:standard)
    end
  end
end
