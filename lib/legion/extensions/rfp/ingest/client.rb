# frozen_string_literal: true

require_relative 'helpers/client'
require_relative 'runners/documents'
require_relative 'runners/corpus'
require_relative 'runners/parser'

module Legion
  module Extensions
    module Rfp
      module Ingest
        class Client
          include Helpers::Client
          include Runners::Documents
          include Runners::Corpus
          include Runners::Parser

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
