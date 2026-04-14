# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Analytics
        module Runners
          module Quality
            extend Legion::Extensions::Rfp::Analytics::Helpers::Client

            QUALITY_DIMENSIONS = %i[completeness relevance clarity compliance].freeze

            def score_response(response_text:, question: nil, requirements: [], **)
              scores = {
                completeness: score_completeness(response_text),
                relevance:    score_relevance(response_text, question),
                clarity:      score_clarity(response_text),
                compliance:   score_compliance(response_text, requirements)
              }

              overall = scores.values.sum.to_f / scores.length
              { result: { scores: scores, overall: overall.round(2) } }
            end

            def score_proposal(sections:, **)
              section_scores = sections.map do |section|
                scored = score_response(
                  response_text: section[:content] || '',
                  question:      section[:question],
                  requirements:  section[:requirements] || []
                )
                { name: section[:name], scores: scored[:result] }
              end

              avg_overall = if section_scores.empty?
                              0.0
                            else
                              section_scores.sum { |s| s[:scores][:overall] } / section_scores.length
                            end

              { result: { sections: section_scores, overall: avg_overall.round(2) } }
            end

            def quality_report(proposals:, **)
              return { result: { count: 0 } } if proposals.empty?

              avg_scores = QUALITY_DIMENSIONS.to_h do |dim|
                scores = proposals.filter_map { |p| p.dig(:quality, :scores, dim) }
                avg = scores.empty? ? 0.0 : (scores.sum.to_f / scores.length).round(2)
                [dim, avg]
              end

              {
                result: {
                  count:          proposals.length,
                  average_scores: avg_scores,
                  overall:        avg_scores.values.sum / avg_scores.length
                }
              }
            end

            private

            def score_completeness(text)
              return 0.0 if text.nil? || text.strip.empty?

              length_score = [text.length / 500.0, 1.0].min
              paragraph_score = [text.split(/\n\n+/).length / 3.0, 1.0].min
              ((length_score + paragraph_score) / 2.0 * 100).round(2)
            end

            def score_relevance(text, question)
              return 50.0 if question.nil? || text.nil?

              keywords = question.to_s.downcase.scan(/\b\w{4,}\b/).uniq
              return 50.0 if keywords.empty?

              text_lower = text.downcase
              matched = keywords.count { |kw| text_lower.include?(kw) }
              ((matched.to_f / keywords.length) * 100).round(2)
            end

            def score_clarity(text)
              return 0.0 if text.nil? || text.strip.empty?

              sentences = text.split(/[.!?]+/).reject(&:empty?)
              return 50.0 if sentences.empty?

              avg_length = sentences.sum { |s| s.split.length }.to_f / sentences.length
              length_score = if avg_length.between?(10, 25)
                               100.0
                             elsif avg_length < 10
                               avg_length * 10.0
                             else
                               [100.0 - ((avg_length - 25) * 2), 0.0].max
                             end
              length_score.round(2)
            end

            def score_compliance(text, requirements)
              return 100.0 if requirements.empty?
              return 0.0 if text.nil?

              text_lower = text.downcase
              matched = requirements.count do |req|
                req_text = (req.is_a?(Hash) ? req[:text] : req).to_s.downcase
                keywords = req_text.scan(/\b\w{4,}\b/).uniq
                keywords.any? { |kw| text_lower.include?(kw) }
              end

              ((matched.to_f / requirements.length) * 100).round(2)
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
