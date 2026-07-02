# app/domains/accounts/services/import_holdings.rb
module Accounts
  class ImportHoldings
    def self.call(firm:, actor:, account:, holdings_data:, ip_address: nil)
      return if holdings_data.empty?

      now = Time.current
      formatted_holdings = holdings_data.map do |data|
        {
          investment_account_id: account.id,
          symbol: data[:symbol],
          description: data[:description],
          quantity: data[:quantity],
          market_value: data[:market_value],
          as_of_date: data[:as_of_date],
          created_at: now,
          updated_at: now
        }
      end

      ActiveRecord::Base.transaction do
        result = Holding.upsert_all(formatted_holdings)

        # Recalculate account value
        RecalculateInvestmentAccountValue.call(account.id)

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "updated",
          auditable: account,
          payload: {
            message: "Bulk imported #{holdings_data.size} holdings",
            inserted_count: result.rows.size
          },
          ip_address: ip_address
        )

        result
      end
    end
  end
end
