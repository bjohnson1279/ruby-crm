# app/domains/accounts/services/create_investment_account.rb
module Accounts
  class CreateInvestmentAccount
    def self.call(firm:, actor:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        account = InvestmentAccount.new(params)
        account.firm = firm
        account.save!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "created",
          auditable: account,
          payload: { changes: account.attributes },
          ip_address: ip_address
        )

        account
      end
    end
  end
end
