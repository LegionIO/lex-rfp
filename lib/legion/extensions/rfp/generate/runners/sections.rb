# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Generate
        module Runners
          module Sections
            extend Legion::Extensions::Rfp::Generate::Helpers::Client

            def generate_section_response(question:, section: nil, context: {}, model: nil, scope: :all, **)
              retrieved = retrieve_section_context(question: question, section: section, scope: scope)
              prompt = build_section_prompt(question: question, section: section, context: context,
                                           retrieved: retrieved)

              answer = call_section_llm(prompt: prompt, model: model)
              {
                result:       answer,
                section:      section,
                question:     question,
                context_used: retrieved.length
              }
            end

            def generate_executive_summary(rfp_text:, company_context: {}, model: nil, **)
              prompt = build_executive_summary_prompt(rfp_text: rfp_text, company_context: company_context)
              answer = call_section_llm(prompt: prompt, model: model)
              { result: answer, type: :executive_summary }
            end

            def generate_compliance_matrix(requirements:, capabilities: {}, model: nil, **)
              prompt = build_compliance_prompt(requirements: requirements, capabilities: capabilities)
              answer = call_section_llm(prompt: prompt, model: model)
              { result: answer, type: :compliance_matrix, requirements_count: requirements.length }
            end

            private

            def retrieve_section_context(question:, section:, scope:)
              return [] unless defined?(Legion::Apollo)

              query = [section, question].compact.join(' - ')
              result = Legion::Apollo.retrieve(query: query, scope: scope, limit: 5)
              result.is_a?(Array) ? result : []
            end

            def build_section_prompt(question:, section:, context:, retrieved:)
              parts = ["You are writing a specific section of an RFP response."]
              parts << "Section: #{section}" if section

              retrieved.each_with_index do |doc, idx|
                parts << "\n--- Reference #{idx + 1} ---\n#{doc[:content] || doc['content']}"
              end

              parts << "\nAdditional context: #{context.inspect}" unless context.empty?
              parts << "\nQuestion: #{question}"
              parts << "\nProvide a focused, professional response for this section."
              parts.join("\n")
            end

            def build_executive_summary_prompt(rfp_text:, company_context:)
              parts = ["Write an executive summary for the following RFP response."]
              parts << "\nCompany context: #{company_context.inspect}" unless company_context.empty?
              parts << "\nRFP overview:\n#{rfp_text[0..2000]}"
              parts << "\nWrite a compelling 2-3 paragraph executive summary."
              parts.join("\n")
            end

            def build_compliance_prompt(requirements:, capabilities:)
              parts = ["Generate a compliance matrix for the following requirements."]
              parts << "\nCapabilities: #{capabilities.inspect}" unless capabilities.empty?

              requirements.each_with_index do |req, idx|
                parts << "#{idx + 1}. #{req[:text] || req}"
              end

              parts << "\nFor each requirement, indicate: Compliant, Partially Compliant, or Non-Compliant with explanation."
              parts.join("\n")
            end

            def call_section_llm(prompt:, model:)
              if defined?(Legion::LLM)
                result = Legion::LLM.ask(message: prompt)
                result.is_a?(Hash) ? (result[:content] || result[:result] || result.to_s) : result.to_s
              else
                "[LLM not available] Prompt: #{prompt[0..100]}..."
              end
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
