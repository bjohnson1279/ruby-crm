# app/domains/accounts/services/recalculate_investment_account_value.rb
module Accounts
  class RecalculateInvestmentAccountValue
    def self.call(account_ids)
      account_ids = Array(account_ids)
      return if account_ids.empty?

      sql = <<~SQL
        UPDATE investment_accounts#{' '}
        SET current_value = (
          SELECT COALESCE(SUM(market_value), 0)#{' '}
          FROM holdings#{' '}
          WHERE holdings.investment_account_id = investment_accounts.id
        )
        WHERE id IN (?)
      SQL

      sanitized_sql = ActiveRecord::Base.sanitize_sql_array([ sql, account_ids ])
      ActiveRecord::Base.connection.execute(sanitized_sql)
    end
  end
end
