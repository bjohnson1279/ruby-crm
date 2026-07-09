# app/domains/opportunities/services/create_opportunity.rb
module Opportunities
  class CreateOpportunity
    def self.call(firm:, actor:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        opportunity = Opportunity.new(params)
        opportunity.firm = firm
        opportunity.save!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "created",
          auditable: opportunity,
          payload: { changes: opportunity.attributes },
          ip_address: ip_address
        )

        opportunity
      end
    end
  end
end
