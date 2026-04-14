# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Ingest::Client do
  subject(:client) { described_class.new }

  it 'includes Documents runner' do
    expect(client).to respond_to(:supported?)
    expect(client).to respond_to(:extract_text)
    expect(client).to respond_to(:chunk_text)
  end

  it 'includes Corpus runner' do
    expect(client).to respond_to(:ingest_document)
    expect(client).to respond_to(:ingest_directory)
  end

  it 'includes Parser runner' do
    expect(client).to respond_to(:parse_rfp_questions)
    expect(client).to respond_to(:extract_requirements)
  end

  it 'stores opts from constructor' do
    client = described_class.new(base_url: 'https://example.com', token: 'abc')
    expect(client.opts).to eq(base_url: 'https://example.com', token: 'abc')
  end

  it 'compacts nil values from opts' do
    client = described_class.new(base_url: nil)
    expect(client.opts).to eq({})
  end
end
