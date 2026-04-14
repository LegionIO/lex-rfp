# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp do
  it 'has a version number' do
    expect(Legion::Extensions::Rfp::VERSION).not_to be_nil
  end

  it 'defines the Ingest sub-module' do
    expect(described_class.const_defined?(:Ingest)).to be true
  end

  it 'defines the Generate sub-module' do
    expect(described_class.const_defined?(:Generate)).to be true
  end

  it 'defines the Review sub-module' do
    expect(described_class.const_defined?(:Review)).to be true
  end

  it 'defines the Analytics sub-module' do
    expect(described_class.const_defined?(:Analytics)).to be true
  end
end
