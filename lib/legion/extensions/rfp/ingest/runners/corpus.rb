# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Ingest
        module Runners
          module Corpus
            extend Legion::Extensions::Rfp::Ingest::Helpers::Client

            def ingest_document(file_path:, tags: [], metadata: {}, **)
              supported = supported?(file_path: file_path)
              return { result: nil, error: "Unsupported format: #{file_path}" } unless supported[:result]

              extracted = extract_text(file_path: file_path)
              chunked = chunk_text(text: extracted[:result])

              ingested = chunked[:result].map.with_index do |chunk, idx|
                {
                  content:  chunk[:text],
                  source:   file_path,
                  chunk_id: idx,
                  tags:     tags,
                  metadata: metadata.merge(format: extracted[:format], offset: chunk[:offset])
                }
              end

              { result: ingested, count: ingested.length, source: file_path }
            end

            def ingest_directory(directory:, tags: [], recursive: true, **)
              pattern = recursive ? ::File.join(directory, '**', '*') : ::File.join(directory, '*')
              files = Dir.glob(pattern).select { |f| ::File.file?(f) }

              results = files.filter_map do |file_path|
                next unless supported?(file_path: file_path)[:result]

                ingest_document(file_path: file_path, tags: tags)
              end

              { result: results, files_processed: results.length, total_chunks: results.sum { |r| r[:count] } }
            end

            def ingest_to_apollo(chunks:, scope: :global, **)
              return { result: nil, error: 'Apollo not available' } unless defined?(Legion::Apollo)

              ingested = chunks.map do |chunk|
                Legion::Apollo.ingest(
                  content:  chunk[:content],
                  tags:     chunk[:tags] || [],
                  metadata: chunk[:metadata] || {},
                  scope:    scope
                )
              end

              { result: ingested, count: ingested.length }
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
