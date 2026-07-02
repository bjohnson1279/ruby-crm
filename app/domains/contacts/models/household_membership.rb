# app/domains/contacts/models/household_membership.rb
module Contacts
  class HouseholdMembership < ApplicationRecord
    self.table_name = "household_memberships"

    belongs_to :household, class_name: "Contacts::Household"
    belongs_to :contact, class_name: "Contacts::Contact"

    validates :role, presence: true
    validates :contact_id, uniqueness: { scope: :household_id, message: "is already a member of this household" }
  end
end
