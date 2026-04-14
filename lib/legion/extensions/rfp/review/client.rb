# frozen_string_literal: true

require_relative 'helpers/client'
require_relative 'runners/workflows'
require_relative 'runners/comments'
require_relative 'runners/approvals'

module Legion
  module Extensions
    module Rfp
      module Review
        class Client
          include Helpers::Client
          include Runners::Workflows
          include Runners::Comments
          include Runners::Approvals

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
