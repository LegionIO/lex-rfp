# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Ingest
        module Runners
          module Parser
            extend Legion::Extensions::Rfp::Ingest::Helpers::Client

            def parse_rfp_questions(text:, **)
              questions = []
              current_section = nil

              text.each_line do |line|
                stripped = line.strip
                next if stripped.empty?

                if stripped.match?(/\A(?:section|part|category)\s+/i) || stripped.match?(/\A[A-Z][A-Z\s]{2,}[A-Z]\z/)
                  current_section = stripped
                elsif stripped.match?(/\A\d+[\.\)]\s/) || stripped.match?(/\A[a-z][\.\)]\s/i)
                  questions << {
                    section:  current_section,
                    question: stripped.sub(/\A[\da-z][\.\)]\s*/i, ''),
                    raw:      stripped
                  }
                end
              end

              { result: questions, count: questions.length }
            end

            def extract_requirements(text:, **)
              requirements = []

              text.each_line do |line|
                stripped = line.strip
                next if stripped.empty?

                if stripped.match?(/\b(?:must|shall|required|mandatory)\b/i)
                  requirements << { text: stripped, type: :mandatory }
                elsif stripped.match?(/\b(?:should|preferred|desired|optional)\b/i)
                  requirements << { text: stripped, type: :preferred }
                end
              end

              { result: requirements, mandatory: requirements.count { |r| r[:type] == :mandatory },
                preferred: requirements.count { |r| r[:type] == :preferred } }
            end

            def extract_sections(text:, **)
              sections = []
              current_title = nil
              current_content = []

              text.each_line do |line|
                stripped = line.strip
                if stripped.match?(/\A(?:#{section_heading_pattern})/)
                  if current_title
                    sections << { title: current_title, content: current_content.join("\n").strip }
                  end
                  current_title = stripped
                  current_content = []
                else
                  current_content << line
                end
              end

              sections << { title: current_title, content: current_content.join("\n").strip } if current_title
              { result: sections, count: sections.length }
            end

            private

            def section_heading_pattern
              '(?:section|part|category|chapter)\s+\d|[A-Z][A-Z\s]{2,}[A-Z]|\d+\.\s+[A-Z]'
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
