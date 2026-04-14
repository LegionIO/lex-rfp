# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Generate
        module Runners
          module Templates
            extend Legion::Extensions::Rfp::Generate::Helpers::Client

            DEFAULT_TEMPLATES = {
              standard:   { sections: %i[executive_summary company_overview approach timeline pricing], tone: :formal },
              government: { sections: %i[executive_summary compliance technical_approach management staffing pricing],
                            tone: :formal },
              healthcare: { sections: %i[executive_summary clinical_approach quality_measures compliance network
                                         implementation pricing], tone: :formal }
            }.freeze

            def list_templates(**)
              { result: DEFAULT_TEMPLATES.keys, count: DEFAULT_TEMPLATES.keys.length }
            end

            def get_template(name:, **)
              template = DEFAULT_TEMPLATES[name.to_sym]
              return { result: nil, error: "Template not found: #{name}" } unless template

              { result: template, name: name }
            end

            def apply_template(name:, rfp_data:, **)
              template = DEFAULT_TEMPLATES[name.to_sym]
              return { result: nil, error: "Template not found: #{name}" } unless template

              outline = template[:sections].map do |section|
                { section: section, tone: template[:tone], content: rfp_data[section] }
              end

              { result: outline, template: name, sections: outline.length }
            end

            def suggest_template(rfp_text:, **)
              text_lower = rfp_text.downcase
              suggested = if text_lower.match?(/\b(?:medicare|medicaid|clinical|hipaa|phi|health)\b/)
                            :healthcare
                          elsif text_lower.match?(/\b(?:federal|government|agency|cfr|far|dfars)\b/)
                            :government
                          else
                            :standard
                          end

              { result: suggested, confidence: :heuristic }
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
