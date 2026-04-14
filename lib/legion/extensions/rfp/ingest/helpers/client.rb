# frozen_string_literal: true

require 'faraday'

module Legion
  module Extensions
    module Rfp
      module Ingest
        module Helpers
          module Client
            def client(base_url: 'http://localhost:4567', token: nil, **)
              Faraday.new(url: base_url) do |conn|
                conn.request :json
                conn.response :json, content_type: /\bjson$/
                conn.headers['Content-Type'] = 'application/json'
                conn.headers['Authorization'] = "Bearer #{token}" if token
              end
            end
          end
        end
      end
    end
  end
end
