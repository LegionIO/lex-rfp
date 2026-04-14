# frozen_string_literal: true

RSpec.describe Legion::Extensions::Rfp::Ingest::Runners::Parser do
  let(:test_class) { Class.new { include Legion::Extensions::Rfp::Ingest::Runners::Parser } }
  let(:instance) { test_class.new }

  describe '#parse_rfp_questions' do
    it 'extracts numbered questions from text' do
      text = <<~TEXT
        SECTION ONE
        1. Describe your approach to healthcare delivery.
        2. What is your network coverage?
      TEXT

      result = instance.parse_rfp_questions(text: text)
      expect(result[:count]).to eq(2)
      expect(result[:result].first[:section]).to eq('SECTION ONE')
      expect(result[:result].first[:question]).to include('Describe your approach')
    end

    it 'returns empty for text with no questions' do
      result = instance.parse_rfp_questions(text: 'Just some plain text without questions.')
      expect(result[:count]).to eq(0)
    end
  end

  describe '#extract_requirements' do
    it 'identifies mandatory requirements' do
      text = "The vendor must provide 24/7 support.\nThe vendor should offer training."
      result = instance.extract_requirements(text: text)
      expect(result[:mandatory]).to eq(1)
      expect(result[:preferred]).to eq(1)
    end

    it 'returns zero counts for text without requirements' do
      result = instance.extract_requirements(text: 'General information about the company.')
      expect(result[:mandatory]).to eq(0)
      expect(result[:preferred]).to eq(0)
    end
  end

  describe '#extract_sections' do
    it 'splits text into sections by headings' do
      text = <<~TEXT
        SECTION OVERVIEW
        This is the overview content.

        SECTION REQUIREMENTS
        These are the requirements.
      TEXT

      result = instance.extract_sections(text: text)
      expect(result[:count]).to eq(2)
      expect(result[:result].first[:title]).to eq('SECTION OVERVIEW')
    end
  end
end
