# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Review::Client do
  subject(:client) { described_class.new }

  it 'includes Workflows runner' do
    expect(client).to respond_to(:create_workflow)
    expect(client).to respond_to(:submit_for_review)
    expect(client).to respond_to(:finalize)
  end

  it 'includes Comments runner' do
    expect(client).to respond_to(:add_comment)
    expect(client).to respond_to(:resolve_comment)
  end

  it 'includes Approvals runner' do
    expect(client).to respond_to(:approve_section)
    expect(client).to respond_to(:reject_section)
    expect(client).to respond_to(:check_readiness)
  end
end
