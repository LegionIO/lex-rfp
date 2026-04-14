# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Review
        module Runners
          module Comments
            extend Legion::Extensions::Rfp::Review::Helpers::Client

            def add_comment(workflow_id:, section_name:, author:, body:, type: :general, **)
              comment = {
                id:          generate_comment_id,
                workflow_id: workflow_id,
                section:     section_name,
                author:      author,
                body:        body,
                type:        type.to_sym,
                created_at:  Time.now.iso8601
              }
              { result: comment }
            end

            def list_comments(workflow_id:, section_name: nil, **)
              {
                result:      [],
                workflow_id: workflow_id,
                section:     section_name,
                error:       'Persistence requires legion-data'
              }
            end

            def resolve_comment(comment_id:, resolved_by:, **)
              {
                result: {
                  id:          comment_id,
                  resolved:    true,
                  resolved_by: resolved_by,
                  resolved_at: Time.now.iso8601
                }
              }
            end

            def request_revision(workflow_id:, section_name:, author:, reason:, **)
              comment = add_comment(
                workflow_id:  workflow_id,
                section_name: section_name,
                author:       author,
                body:         reason,
                type:         :revision_request
              )

              {
                result: {
                  comment:     comment[:result],
                  section:     section_name,
                  new_status:  :revision_requested,
                  workflow_id: workflow_id
                }
              }
            end

            private

            def generate_comment_id
              "rfp-cmt-#{Time.now.to_i}-#{rand(10_000)}"
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
