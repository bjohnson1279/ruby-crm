# app/domains/accounts/queries/investment_account_index_query.rb
module Accounts
  class InvestmentAccountIndexQuery
    def self.call(firm:, status: nil)
      relation = InvestmentAccount.strict_loading
                                   .for_firm(firm)
                                   .preload(:account_type, :contact, :household)
                                   .order(:id)

      relation = relation.where(status: status) if status.present?
      relation
    end
  end
end
