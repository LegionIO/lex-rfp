# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Analytics
        module Runners
          module WinRates
            extend Legion::Extensions::Rfp::Analytics::Helpers::Client

            def overall_win_rate(proposals:, **)
              decided = proposals.select { |p| %i[won lost].include?(p[:outcome]) }
              return { result: 0.0, decided: 0, total: proposals.length } if decided.empty?

              won = decided.count { |p| p[:outcome] == :won }
              { result: (won.to_f / decided.length).round(4), won: won, decided: decided.length }
            end

            def win_rate_by_source(proposals:, **)
              grouped = proposals.group_by { |p| p[:rfp_source] }
              rates = grouped.transform_values do |group|
                decided = group.select { |p| %i[won lost].include?(p[:outcome]) }
                next { rate: 0.0, decided: 0 } if decided.empty?

                won = decided.count { |p| p[:outcome] == :won }
                { rate: (won.to_f / decided.length).round(4), won: won, decided: decided.length }
              end

              { result: rates }
            end

            def win_rate_by_template(proposals:, **)
              grouped = proposals.group_by { |p| p[:template] }
              rates = grouped.transform_values do |group|
                decided = group.select { |p| %i[won lost].include?(p[:outcome]) }
                next { rate: 0.0, decided: 0 } if decided.empty?

                won = decided.count { |p| p[:outcome] == :won }
                { rate: (won.to_f / decided.length).round(4), won: won, decided: decided.length }
              end

              { result: rates }
            end

            def trend(proposals:, period: :monthly, **)
              sorted = proposals.sort_by { |p| p[:submitted_at] || '' }
              grouped = case period
                        when :monthly
                          sorted.group_by { |p| p[:submitted_at]&.slice(0, 7) }
                        when :quarterly
                          sorted.group_by { |p| quarter_key(p[:submitted_at]) }
                        else
                          sorted.group_by { |p| p[:submitted_at]&.slice(0, 4) }
                        end

              trend_data = grouped.transform_values do |group|
                decided = group.select { |p| %i[won lost].include?(p[:outcome]) }
                won = decided.count { |p| p[:outcome] == :won }
                {
                  total:   group.length,
                  decided: decided.length,
                  won:     won,
                  rate:    decided.empty? ? 0.0 : (won.to_f / decided.length).round(4)
                }
              end

              { result: trend_data, period: period }
            end

            private

            def quarter_key(date_str)
              return nil unless date_str

              year = date_str[0, 4]
              month = date_str[5, 2].to_i
              quarter = ((month - 1) / 3) + 1
              "#{year}-Q#{quarter}"
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
