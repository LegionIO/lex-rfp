# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Review::Runners::Comments do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Review::Runners::Comments } }
  let(:instance) { test_class.new }

  describe '#add_comment' do
    it 'creates a comment' do
      result = instance.add_comment(
        workflow_id:  'wf-1',
        section_name: 'pricing',
        author:       'reviewer-1',
        body:         'Needs more detail on pricing tiers'
      )
      comment = result[:result]
      expect(comment[:author]).to eq('reviewer-1')
      expect(comment[:body]).to include('pricing tiers')
      expect(comment[:type]).to eq(:general)
    end
  end

  describe '#resolve_comment' do
    it 'resolves a comment' do
      result = instance.resolve_comment(comment_id: 'cmt-1', resolved_by: 'author-1')
      expect(result[:result][:resolved]).to be true
      expect(result[:result][:resolved_by]).to eq('author-1')
    end
  end

  describe '#request_revision' do
    it 'creates a revision request comment' do
      result = instance.request_revision(
        workflow_id:  'wf-1',
        section_name: 'approach',
        author:       'reviewer-1',
        reason:       'Missing compliance details'
      )
      expect(result[:result][:new_status]).to eq(:revision_requested)
      expect(result[:result][:comment][:type]).to eq(:revision_request)
    end
  end
end
