# app/domains/contacts/models/contact.rb
module Contacts
  class Contact < ApplicationRecord
    self.table_name = "contacts"

    include FirmScoped
    include Auditable

    has_many :household_memberships, class_name: "Contacts::HouseholdMembership", dependent: :destroy
    has_many :households, through: :household_memberships, class_name: "Contacts::Household"

    has_many :relationships, class_name: "Contacts::Relationship", dependent: :destroy

    # Financial accounts owned by the contact
    has_many :investment_accounts, class_name: "Accounts::InvestmentAccount", foreign_key: :contact_id

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    def name
      "#{first_name} #{last_name}"
    end
  end
end
