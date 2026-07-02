# app/domains/accounts/models/holding.rb
module Accounts
  class Holding < ApplicationRecord
    self.table_name = "holdings"

    include Auditable

    belongs_to :investment_account, class_name: "Accounts::InvestmentAccount"

    validates :symbol, presence: true
    validates :quantity, presence: true, numericality: true
    validates :market_value, presence: true, numericality: true
    validates :as_of_date, presence: true

    validates :symbol, uniqueness: { scope: [:investment_account_id, :as_of_date], message: "already has a position for this date" }
  end
end
