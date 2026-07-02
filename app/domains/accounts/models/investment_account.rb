# app/domains/accounts/models/investment_account.rb
module Accounts
  class InvestmentAccount < ApplicationRecord
    self.table_name = "investment_accounts"

    include FirmScoped
    include Auditable

    belongs_to :contact, class_name: "Contacts::Contact"
    belongs_to :household, class_name: "Contacts::Household"
    belongs_to :account_type, class_name: "Accounts::AccountType"

    has_many :holdings, class_name: "Accounts::Holding", foreign_key: :investment_account_id, dependent: :destroy

    validates :account_number, presence: true, uniqueness: { scope: :firm_id, message: "already exists for this firm" }
    validates :status, presence: true
    validates :current_value, presence: true, numericality: true
  end
end
