# frozen_string_literal: true

require_relative 'helpers/client'
require_relative 'runners/drafts'
require_relative 'runners/sections'
require_relative 'runners/templates'

module Legion
  module Extensions
    module Rfp
      module Generate
        class Client
          include Helpers::Client
          include Runners::Drafts
          include Runners::Sections
          include Runners::Templates

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
