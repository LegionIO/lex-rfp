# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Review
        module Runners
          module Workflows
            extend Legion::Extensions::Rfp::Review::Helpers::Client

            STATUSES = %i[draft in_review revision_requested approved rejected finalized].freeze

            def create_workflow(proposal_id:, sections: [], reviewers: [], **)
              workflow = {
                id:          generate_workflow_id,
                proposal_id: proposal_id,
                status:      :draft,
                sections:    sections.map { |s| { name: s, status: :draft, reviewer: nil, comments: [] } },
                reviewers:   reviewers,
                created_at:  Time.now.iso8601,
                updated_at:  Time.now.iso8601
              }
              { result: workflow }
            end

            def get_workflow(workflow_id:, **)
              { result: { id: workflow_id, status: :draft }, error: 'Persistence requires legion-data' }
            end

            def update_status(workflow_id:, status:, **)
              status_sym = status.to_sym
              unless STATUSES.include?(status_sym)
                return { result: nil, error: "Invalid status: #{status}. Valid: #{STATUSES.join(', ')}" }
              end

              { result: { id: workflow_id, status: status_sym, updated_at: Time.now.iso8601 } }
            end

            def update_section_status(workflow_id:, section_name:, status:, reviewer: nil, **)
              status_sym = status.to_sym
              unless STATUSES.include?(status_sym)
                return { result: nil, error: "Invalid status: #{status}" }
              end

              {
                result: {
                  workflow_id:  workflow_id,
                  section:      section_name,
                  status:       status_sym,
                  reviewer:     reviewer,
                  updated_at:   Time.now.iso8601
                }
              }
            end

            def submit_for_review(workflow_id:, reviewers:, **)
              {
                result: {
                  workflow_id: workflow_id,
                  status:      :in_review,
                  reviewers:   reviewers,
                  submitted_at: Time.now.iso8601
                }
              }
            end

            def finalize(workflow_id:, **)
              {
                result: {
                  workflow_id:  workflow_id,
                  status:       :finalized,
                  finalized_at: Time.now.iso8601
                }
              }
            end

            private

            def generate_workflow_id
              "rfp-wf-#{Time.now.to_i}-#{rand(10_000)}"
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
