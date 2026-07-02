# app/models/firm.rb
class Firm < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :contacts, class_name: "Contacts::Contact", dependent: :destroy
  has_many :households, class_name: "Contacts::Household", dependent: :destroy
  has_many :investment_accounts, class_name: "Accounts::InvestmentAccount", dependent: :destroy
  has_many :account_types, class_name: "Accounts::AccountType", dependent: :destroy
  has_many :audit_events, class_name: "Compliance::AuditEvent", dependent: :destroy
end
