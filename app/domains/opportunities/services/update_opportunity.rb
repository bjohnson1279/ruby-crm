# app/domains/opportunities/services/update_opportunity.rb
module Opportunities
  class UpdateOpportunity
    def self.call(firm:, actor:, opportunity:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        old_attrs = opportunity.attributes.clone
        opportunity.update!(params)

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "updated",
          auditable: opportunity,
          payload: { before: old_attrs, after: opportunity.attributes },
          ip_address: ip_address
        )

        opportunity
      end
    end
  end
end
