# app/domains/accounts/queries/aum_by_contact_query.rb
module Accounts
  class AumByContactQuery
    Result = Data.define(:contact_id, :first_name, :last_name, :total_aum, :account_count)

    def self.call(firm_id:, limit: 25)
      sql = <<~SQL
        SELECT c.id AS contact_id,
               c.first_name,
               c.last_name,
               COALESCE(SUM(a.current_value), 0) AS total_aum,
               COUNT(a.id) AS account_count
        FROM contacts c
        LEFT JOIN investment_accounts a ON a.contact_id = c.id AND a.status = 'active'
        WHERE c.firm_id = ?
        GROUP BY c.id, c.first_name, c.last_name
        ORDER BY total_aum DESC, c.id ASC
        LIMIT ?
      SQL

      sanitized_sql = ActiveRecord::Base.sanitize_sql_array([ sql, firm_id, limit ])
      rows = ActiveRecord::Base.connection.exec_query(sanitized_sql, "AUM by contact")

      rows.map do |row|
        Result.new(
          contact_id: row["contact_id"].to_i,
          first_name: row["first_name"],
          last_name: row["last_name"],
          total_aum: BigDecimal(row["total_aum"].to_s),
          account_count: row["account_count"].to_i
        )
      end
    end
  end
end
