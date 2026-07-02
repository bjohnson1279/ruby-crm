# app/domains/contacts/services/create_household.rb
module Contacts
  class CreateHousehold
    def self.call(firm:, actor:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        household = Household.new(params)
        household.firm = firm
        household.save!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "created",
          auditable: household,
          payload: { changes: household.attributes },
          ip_address: ip_address
        )

        household
      end
    end
  end
end
