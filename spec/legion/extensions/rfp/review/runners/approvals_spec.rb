# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Review::Runners::Approvals do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Review::Runners::Approvals } }
  let(:instance) { test_class.new }

  describe '#approve_section' do
    it 'approves a section' do
      result = instance.approve_section(workflow_id: 'wf-1', section_name: 'pricing', approved_by: 'mgr-1')
      expect(result[:result][:status]).to eq(:approved)
      expect(result[:result][:approved_by]).to eq('mgr-1')
    end
  end

  describe '#reject_section' do
    it 'rejects a section with reason' do
      result = instance.reject_section(
        workflow_id:  'wf-1',
        section_name: 'approach',
        rejected_by:  'mgr-1',
        reason:       'Does not meet compliance requirements'
      )
      expect(result[:result][:status]).to eq(:rejected)
      expect(result[:result][:reason]).to include('compliance')
    end
  end

  describe '#approve_proposal' do
    it 'approves the full proposal' do
      result = instance.approve_proposal(workflow_id: 'wf-1', approved_by: 'director-1')
      expect(result[:result][:status]).to eq(:approved)
    end
  end

  describe '#check_readiness' do
    it 'returns ready when all sections approved' do
      sections = [
        { name: 'summary', status: :approved },
        { name: 'pricing', status: :approved }
      ]
      result = instance.check_readiness(sections: sections)
      expect(result[:result][:ready]).to be true
      expect(result[:result][:approved]).to eq(2)
    end

    it 'returns not ready with pending sections' do
      sections = [
        { name: 'summary', status: :approved },
        { name: 'pricing', status: :draft }
      ]
      result = instance.check_readiness(sections: sections)
      expect(result[:result][:ready]).to be false
      expect(result[:result][:pending_sections]).to eq(['pricing'])
    end
  end
end
