# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Ingest::Runners::Documents do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Ingest::Runners::Documents } }
  let(:instance) { test_class.new }

  describe '#supported?' do
    it 'returns true for PDF files' do
      result = instance.supported?(file_path: 'proposal.pdf')
      expect(result[:result]).to be true
      expect(result[:format]).to eq('pdf')
    end

    it 'returns true for DOCX files' do
      result = instance.supported?(file_path: 'proposal.docx')
      expect(result[:result]).to be true
    end

    it 'returns true for Markdown files' do
      result = instance.supported?(file_path: 'proposal.md')
      expect(result[:result]).to be true
    end

    it 'returns true for Excel files' do
      result = instance.supported?(file_path: 'data.xlsx')
      expect(result[:result]).to be true
    end

    it 'returns true for HTML files' do
      result = instance.supported?(file_path: 'page.html')
      expect(result[:result]).to be true
    end

    it 'returns false for unsupported formats' do
      result = instance.supported?(file_path: 'image.png')
      expect(result[:result]).to be false
    end
  end

  describe '#extract_text' do
    it 'reads markdown files directly' do
      tmpfile = Tempfile.new(['test', '.md'])
      tmpfile.write('# Test Heading\n\nSome content here.')
      tmpfile.close

      result = instance.extract_text(file_path: tmpfile.path)
      expect(result[:result]).to include('Test Heading')
      expect(result[:format]).to eq('md')
      expect(result[:size]).to be_positive
    ensure
      tmpfile&.unlink
    end

    it 'strips HTML tags from HTML files' do
      tmpfile = Tempfile.new(['test', '.html'])
      tmpfile.write('<html><body><p>Hello World</p><script>alert("x")</script></body></html>')
      tmpfile.close

      result = instance.extract_text(file_path: tmpfile.path)
      expect(result[:result]).to include('Hello World')
      expect(result[:result]).not_to include('<p>')
      expect(result[:result]).not_to include('alert')
    ensure
      tmpfile&.unlink
    end

    it 'raises for unsupported formats' do
      expect { instance.extract_text(file_path: 'file.xyz') }.to raise_error(ArgumentError, /Unsupported format/)
    end
  end

  describe '#chunk_text' do
    it 'splits text into overlapping chunks' do
      text = 'a' * 2500
      result = instance.chunk_text(text: text, chunk_size: 1000, overlap: 200)
      expect(result[:count]).to eq(4)
      expect(result[:result].first[:offset]).to eq(0)
      expect(result[:result][1][:offset]).to eq(800)
    end

    it 'returns empty array for nil text' do
      result = instance.chunk_text(text: nil)
      expect(result[:result]).to eq([])
      expect(result[:count]).to eq(0)
    end

    it 'returns empty array for empty text' do
      result = instance.chunk_text(text: '')
      expect(result[:result]).to eq([])
    end
  end
end
