# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Review::Runners::Workflows do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Review::Runners::Workflows } }
  let(:instance) { test_class.new }

  describe '#create_workflow' do
    it 'creates a new workflow' do
      result = instance.create_workflow(
        proposal_id: 'prop-123',
        sections:    %w[executive_summary approach pricing],
        reviewers:   ['reviewer-1']
      )
      wf = result[:result]
      expect(wf[:proposal_id]).to eq('prop-123')
      expect(wf[:status]).to eq(:draft)
      expect(wf[:sections].length).to eq(3)
    end
  end

  describe '#update_status' do
    it 'updates workflow status' do
      result = instance.update_status(workflow_id: 'wf-1', status: 'in_review')
      expect(result[:result][:status]).to eq(:in_review)
    end

    it 'rejects invalid status' do
      result = instance.update_status(workflow_id: 'wf-1', status: 'invalid')
      expect(result[:error]).to include('Invalid status')
    end
  end

  describe '#submit_for_review' do
    it 'submits workflow for review' do
      result = instance.submit_for_review(workflow_id: 'wf-1', reviewers: %w[rev-1 rev-2])
      expect(result[:result][:status]).to eq(:in_review)
      expect(result[:result][:reviewers]).to eq(%w[rev-1 rev-2])
    end
  end

  describe '#finalize' do
    it 'finalizes a workflow' do
      result = instance.finalize(workflow_id: 'wf-1')
      expect(result[:result][:status]).to eq(:finalized)
    end
  end
end
