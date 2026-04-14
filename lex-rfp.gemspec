# frozen_string_literal: true

require_relative 'lib/legion/extensions/rfp/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-rfp'
  spec.version       = Legion::Extensions::Rfp::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Rfp'
  spec.description   = 'Generative AI-powered RFP and proposal automation for LegionIO. ' \
                       'Ingests past proposals into Apollo, generates draft responses via LLM pipeline with RAG, ' \
                       'and provides human-in-the-loop review workflows with analytics.'
  spec.homepage      = 'https://github.com/LegionIO/lex-rfp'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LegionIO/lex-rfp'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-rfp'
  spec.metadata['changelog_uri'] = 'https://github.com/LegionIO/lex-rfp/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/LegionIO/lex-rfp/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 2.0'
end
