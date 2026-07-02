# app/domains/accounts/models/account_type.rb
module Accounts
  class AccountType < ApplicationRecord
    self.table_name = "account_types"

    include FirmScoped

    has_many :investment_accounts, class_name: "Accounts::InvestmentAccount", foreign_key: :account_type_id

    validates :name, presence: true, uniqueness: { scope: :firm_id, message: "already exists for this firm" }
  end
end
