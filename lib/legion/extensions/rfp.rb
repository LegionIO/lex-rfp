# frozen_string_literal: true

require 'legion/extensions/rfp/version'
require_relative 'rfp/ingest'
require_relative 'rfp/generate'
require_relative 'rfp/review'
require_relative 'rfp/analytics'

module Legion
  module Extensions
    module Rfp
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
