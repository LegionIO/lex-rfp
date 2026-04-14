# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Ingest::Runners::Corpus do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Ingest::Runners::Corpus } }
  let(:instance) { test_class.new }

  describe '#ingest_document' do
    it 'ingests a supported document and returns chunks' do
      tmpfile = Tempfile.new(['proposal', '.md'])
      tmpfile.write('# RFP Response\n\n' + ('Content paragraph. ' * 100))
      tmpfile.close

      result = instance.ingest_document(file_path: tmpfile.path, tags: ['rfp', 'test'])
      expect(result[:count]).to be_positive
      expect(result[:source]).to eq(tmpfile.path)
      expect(result[:result].first[:tags]).to eq(['rfp', 'test'])
    ensure
      tmpfile&.unlink
    end

    it 'returns error for unsupported format' do
      result = instance.ingest_document(file_path: 'file.xyz')
      expect(result[:error]).to include('Unsupported')
    end
  end

  describe '#ingest_directory' do
    it 'processes all supported files in a directory' do
      dir = Dir.mktmpdir
      File.write(File.join(dir, 'a.md'), 'content a')
      File.write(File.join(dir, 'b.md'), 'content b')
      File.write(File.join(dir, 'c.png'), 'not supported')

      result = instance.ingest_directory(directory: dir, tags: ['batch'])
      expect(result[:files_processed]).to eq(2)
    ensure
      FileUtils.remove_entry(dir) if dir
    end
  end
end
