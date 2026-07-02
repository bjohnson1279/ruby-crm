# app/domains/contacts/queries/household_detail_query.rb
module Contacts
  class HouseholdDetailQuery
    def self.call(firm:, id:)
      Household.strict_loading
               .for_firm(firm)
               .includes(
                 :primary_contact,
                 household_memberships: { contact: { relationships: :related_contact } },
                 investment_accounts: :account_type
               )
               .find(id)
    end
  end
end
