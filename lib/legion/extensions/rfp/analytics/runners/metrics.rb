# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Analytics
        module Runners
          module Metrics
            extend Legion::Extensions::Rfp::Analytics::Helpers::Client

            def record_proposal(proposal_id:, rfp_source:, submitted_at: nil, sections: 0, word_count: 0, **)
              metric = {
                proposal_id:  proposal_id,
                rfp_source:   rfp_source,
                submitted_at: submitted_at || Time.now.iso8601,
                sections:     sections,
                word_count:   word_count,
                recorded_at:  Time.now.iso8601
              }
              { result: metric }
            end

            def record_outcome(proposal_id:, outcome:, revenue: nil, feedback: nil, **)
              valid_outcomes = %i[won lost no_decision pending]
              outcome_sym = outcome.to_sym
              unless valid_outcomes.include?(outcome_sym)
                return { result: nil, error: "Invalid outcome: #{outcome}. Valid: #{valid_outcomes.join(', ')}" }
              end

              {
                result: {
                  proposal_id: proposal_id,
                  outcome:     outcome_sym,
                  revenue:     revenue,
                  feedback:    feedback,
                  recorded_at: Time.now.iso8601
                }
              }
            end

            def summary(proposals:, **)
              total = proposals.length
              won = proposals.count { |p| p[:outcome] == :won }
              lost = proposals.count { |p| p[:outcome] == :lost }
              pending = proposals.count { |p| p[:outcome] == :pending || p[:outcome].nil? }
              total_revenue = proposals.select { |p| p[:outcome] == :won }.sum { |p| p[:revenue].to_f }

              {
                result: {
                  total_proposals: total,
                  won:             won,
                  lost:            lost,
                  pending:         pending,
                  win_rate:        total.positive? ? (won.to_f / (won + lost)).round(4) : 0.0,
                  total_revenue:   total_revenue
                }
              }
            end

            def response_time_stats(proposals:, **)
              times = proposals.filter_map do |p|
                next unless p[:created_at] && p[:submitted_at]

                created = Time.parse(p[:created_at])
                submitted = Time.parse(p[:submitted_at])
                (submitted - created).to_f
              end

              return { result: { count: 0 } } if times.empty?

              {
                result: {
                  count:   times.length,
                  avg:     (times.sum / times.length).round(2),
                  min:     times.min.round(2),
                  max:     times.max.round(2),
                  median:  times.sort[times.length / 2].round(2)
                }
              }
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
