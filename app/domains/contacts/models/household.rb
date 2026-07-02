# app/domains/contacts/models/household.rb
module Contacts
  class Household < ApplicationRecord
    self.table_name = "households"

    include FirmScoped
    include Auditable

    belongs_to :primary_contact, class_name: "Contacts::Contact", optional: true

    has_many :household_memberships, class_name: "Contacts::HouseholdMembership", dependent: :destroy
    has_many :members, through: :household_memberships, source: :contact, class_name: "Contacts::Contact"

    has_many :investment_accounts, class_name: "Accounts::InvestmentAccount", foreign_key: :household_id

    validates :name, presence: true
  end
end
