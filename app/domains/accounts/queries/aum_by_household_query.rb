# app/domains/accounts/queries/aum_by_household_query.rb
module Accounts
  class AumByHouseholdQuery
    Result = Data.define(:household_id, :name, :total_aum, :account_count)

    def self.call(firm_id:, limit: 25)
      sql = <<~SQL
        SELECT h.id AS household_id,
               h.name,
               COALESCE(SUM(a.current_value), 0) AS total_aum,
               COUNT(a.id) AS account_count
        FROM households h
        LEFT JOIN investment_accounts a ON a.household_id = h.id AND a.status = 'active'
        WHERE h.firm_id = ?
        GROUP BY h.id, h.name
        ORDER BY total_aum DESC, h.id ASC
        LIMIT ?
      SQL

      sanitized_sql = ActiveRecord::Base.sanitize_sql_array([ sql, firm_id, limit ])
      rows = ActiveRecord::Base.connection.exec_query(sanitized_sql, "AUM by household")

      rows.map do |row|
        Result.new(
          household_id: row["household_id"].to_i,
          name: row["name"],
          total_aum: BigDecimal(row["total_aum"].to_s),
          account_count: row["account_count"].to_i
        )
      end
    end
  end
end
