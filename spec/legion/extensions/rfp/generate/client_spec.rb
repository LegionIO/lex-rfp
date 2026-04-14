# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Generate::Client do
  subject(:client) { described_class.new }

  it 'includes Drafts runner' do
    expect(client).to respond_to(:generate_response)
    expect(client).to respond_to(:generate_full_draft)
    expect(client).to respond_to(:regenerate)
  end

  it 'includes Sections runner' do
    expect(client).to respond_to(:generate_section_response)
    expect(client).to respond_to(:generate_executive_summary)
    expect(client).to respond_to(:generate_compliance_matrix)
  end

  it 'includes Templates runner' do
    expect(client).to respond_to(:list_templates)
    expect(client).to respond_to(:suggest_template)
  end

  it 'stores opts from constructor' do
    client = described_class.new(base_url: 'https://api.example.com', token: 'tok')
    expect(client.opts).to eq(base_url: 'https://api.example.com', token: 'tok')
  end
end
