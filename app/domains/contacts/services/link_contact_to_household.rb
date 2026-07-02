# app/domains/contacts/services/link_contact_to_household.rb
module Contacts
  class LinkContactToHousehold
    def self.call(firm:, actor:, household:, contact:, role: "member", ip_address: nil)
      ActiveRecord::Base.transaction do
        membership = HouseholdMembership.create!(
          household: household,
          contact: contact,
          role: role
        )

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "updated",
          auditable: household,
          payload: {
            message: "Added contact #{contact.name} (ID: #{contact.id}) as #{role} to household",
            membership_id: membership.id
          },
          ip_address: ip_address
        )

        membership
      end
    end
  end
end
