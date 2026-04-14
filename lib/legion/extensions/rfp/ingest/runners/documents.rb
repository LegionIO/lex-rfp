# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Ingest
        module Runners
          module Documents
            extend Legion::Extensions::Rfp::Ingest::Helpers::Client

            SUPPORTED_FORMATS = %w[pdf docx md markdown xlsx html htm].freeze

            def supported?(file_path:, **)
              ext = ::File.extname(file_path.to_s).delete('.').downcase
              { result: SUPPORTED_FORMATS.include?(ext), format: ext }
            end

            def extract_text(file_path:, format: nil, **)
              fmt = format || ::File.extname(file_path.to_s).delete('.').downcase
              content = case fmt
                        when 'pdf'      then extract_pdf(file_path)
                        when 'docx'     then extract_docx(file_path)
                        when 'md', 'markdown' then ::File.read(file_path)
                        when 'xlsx'     then extract_xlsx(file_path)
                        when 'html', 'htm' then extract_html(file_path)
                        else raise ArgumentError, "Unsupported format: #{fmt}"
                        end
              { result: content, format: fmt, size: content.length }
            end

            def chunk_text(text:, chunk_size: 1000, overlap: 200, **)
              return { result: [], count: 0 } if text.nil? || text.empty?

              chunks = []
              pos = 0
              while pos < text.length
                chunk = text[pos, chunk_size]
                chunks << { text: chunk, offset: pos, length: chunk.length }
                pos += (chunk_size - overlap)
              end
              { result: chunks, count: chunks.length }
            end

            private

            def extract_pdf(file_path)
              if defined?(Legion::Data::Extract)
                Legion::Data::Extract.call(file_path, :pdf)
              else
                "[PDF extraction requires legion-data] #{file_path}"
              end
            end

            def extract_docx(file_path)
              if defined?(Legion::Data::Extract)
                Legion::Data::Extract.call(file_path, :docx)
              else
                "[DOCX extraction requires legion-data] #{file_path}"
              end
            end

            def extract_xlsx(file_path)
              if defined?(Legion::Data::Extract)
                Legion::Data::Extract.call(file_path, :xlsx)
              else
                "[Excel extraction requires legion-data] #{file_path}"
              end
            end

            def extract_html(file_path)
              content = ::File.read(file_path)
              content.gsub(%r{<script[^>]*>.*?</script>}mi, '')
                     .gsub(%r{<style[^>]*>.*?</style>}mi, '')
                     .gsub(/<[^>]+>/, ' ')
                     .gsub(/\s+/, ' ')
                     .strip
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
