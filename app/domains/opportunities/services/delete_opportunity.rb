# app/domains/opportunities/services/delete_opportunity.rb
module Opportunities
  class DeleteOpportunity
    def self.call(firm:, actor:, opportunity:, ip_address: nil)
      ActiveRecord::Base.transaction do
        old_attrs = opportunity.attributes.clone
        opportunity.destroy!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "deleted",
          auditable: opportunity,
          payload: { changes: old_attrs },
          ip_address: ip_address
        )

        opportunity
      end
    end
  end
end
