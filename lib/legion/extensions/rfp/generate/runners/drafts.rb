# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Generate
        module Runners
          module Drafts
            extend Legion::Extensions::Rfp::Generate::Helpers::Client

            def generate_full_draft(rfp_text:, context: {}, model: nil, **)
              questions = parse_rfp(rfp_text)
              responses = questions.map do |question|
                generate_section_response(question: question[:question], section: question[:section], context: context,
                                          model: model)
              end

              draft = responses.map { |r| r[:result] }.join("\n\n---\n\n")
              { result: draft, sections: responses.length, questions_answered: responses.length }
            end

            def generate_response(question:, context: {}, model: nil, scope: :all, **)
              retrieved = retrieve_context(question: question, scope: scope)
              prompt = build_prompt(question: question, context: context, retrieved: retrieved)

              answer = call_llm(prompt: prompt, model: model)
              { result: answer, context_used: retrieved.length, question: question }
            end

            def regenerate(question:, previous_answer:, feedback:, context: {}, model: nil, **)
              prompt = build_revision_prompt(
                question: question,
                previous: previous_answer,
                feedback: feedback,
                context:  context
              )

              answer = call_llm(prompt: prompt, model: model)
              { result: answer, question: question, revision: true }
            end

            private

            def parse_rfp(text)
              parser = Legion::Extensions::Rfp::Ingest::Runners::Parser
              parsed = parser.parse_rfp_questions(text: text)
              parsed[:result]
            end

            def retrieve_context(question:, scope:)
              return [] unless defined?(Legion::Apollo)

              result = Legion::Apollo.retrieve(query: question, scope: scope, limit: 5)
              result.is_a?(Array) ? result : []
            end

            def build_prompt(question:, context:, retrieved:)
              parts = ["You are an expert proposal writer for a healthcare organization."]
              parts << "Use the following reference material to craft your response:"

              retrieved.each_with_index do |doc, idx|
                parts << "\n--- Reference #{idx + 1} ---\n#{doc[:content] || doc['content']}"
              end

              parts << "\nAdditional context: #{context.inspect}" unless context.empty?
              parts << "\nQuestion: #{question}"
              parts << "\nProvide a professional, detailed response suitable for an RFP submission."
              parts.join("\n")
            end

            def build_revision_prompt(question:, previous:, feedback:, context:)
              parts = ["You are revising an RFP response based on reviewer feedback."]
              parts << "\nOriginal question: #{question}"
              parts << "\nPrevious answer:\n#{previous}"
              parts << "\nReviewer feedback: #{feedback}"
              parts << "\nAdditional context: #{context.inspect}" unless context.empty?
              parts << "\nProvide an improved response incorporating the feedback."
              parts.join("\n")
            end

            def call_llm(prompt:, model:)
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
