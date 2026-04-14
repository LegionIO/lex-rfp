# frozen_string_literal: true

module Legion
  module Extensions
    module Rfp
      module Review
        module Runners
          module Approvals
            extend Legion::Extensions::Rfp::Review::Helpers::Client

            def approve_section(workflow_id:, section_name:, approved_by:, notes: nil, **)
              {
                result: {
                  workflow_id: workflow_id,
                  section:     section_name,
                  status:      :approved,
                  approved_by: approved_by,
                  notes:       notes,
                  approved_at: Time.now.iso8601
                }
              }
            end

            def reject_section(workflow_id:, section_name:, rejected_by:, reason:, **)
              {
                result: {
                  workflow_id: workflow_id,
                  section:     section_name,
                  status:      :rejected,
                  rejected_by: rejected_by,
                  reason:      reason,
                  rejected_at: Time.now.iso8601
                }
              }
            end

            def approve_proposal(workflow_id:, approved_by:, notes: nil, **)
              {
                result: {
                  workflow_id: workflow_id,
                  status:      :approved,
                  approved_by: approved_by,
                  notes:       notes,
                  approved_at: Time.now.iso8601
                }
              }
            end

            def check_readiness(sections:, **)
              all_approved = sections.all? { |s| s[:status] == :approved }
              pending = sections.reject { |s| s[:status] == :approved }

              {
                result: {
                  ready:           all_approved,
                  total_sections:  sections.length,
                  approved:        sections.count { |s| s[:status] == :approved },
                  pending_sections: pending.map { |s| s[:name] }
                }
              }
            end

            include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                        Legion::Extensions::Helpers.const_defined?(:Lex)
          end
        end
      end
    end
  end
end
