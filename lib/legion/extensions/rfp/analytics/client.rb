# frozen_string_literal: true

require_relative 'helpers/client'
require_relative 'runners/metrics'
require_relative 'runners/win_rates'
require_relative 'runners/quality'

module Legion
  module Extensions
    module Rfp
      module Analytics
        class Client
          include Helpers::Client
          include Runners::Metrics
          include Runners::WinRates
          include Runners::Quality

          attr_reader :opts

          def initialize(base_url: nil, token: nil, **)
            @opts = { base_url: base_url, token: token }.compact
          end

          def client(**override)
            super(**@opts, **override)
          end
        end
      end
    end
  end
end
