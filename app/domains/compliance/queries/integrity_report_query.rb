# app/domains/compliance/queries/integrity_report_query.rb
module Compliance
  class IntegrityReportQuery
    def self.call(firm_id:, threshold_days: 7)
      threshold_date = threshold_days.days.ago.to_date

      # 1. Orphaned Accounts (where account owner contact is not in the account's linked household)
      orphaned_sql = <<~SQL
        SELECT a.id AS account_id, a.account_number, a.custodian,#{' '}
               c.id AS contact_id, c.first_name, c.last_name,#{' '}
               h.id AS household_id, h.name AS household_name
        FROM investment_accounts a
        JOIN contacts c ON a.contact_id = c.id
        JOIN households h ON a.household_id = h.id
        LEFT JOIN household_memberships m ON m.household_id = h.id AND m.contact_id = c.id
        WHERE a.firm_id = ? AND m.id IS NULL
      SQL

      # 2. Households without primary contact (either null primary_contact_id or contact isn't a primary member)
      households_sql = <<~SQL
        SELECT h.id AS household_id, h.name AS household_name, h.primary_contact_id
        FROM households h
        LEFT JOIN household_memberships m ON m.household_id = h.id AND m.contact_id = h.primary_contact_id AND m.role = 'primary'
        WHERE h.firm_id = ? AND (h.primary_contact_id IS NULL OR m.id IS NULL)
      SQL

      # 3. AUM Drift (accounts where denormalized current_value != SUM(holdings.market_value))
      drift_sql = <<~SQL
        SELECT a.id AS account_id, a.account_number, a.current_value AS denormalized_value,#{' '}
               COALESCE(SUM(ho.market_value), 0) AS actual_value,#{' '}
               ABS(a.current_value - COALESCE(SUM(ho.market_value), 0)) AS drift_amount
        FROM investment_accounts a
        LEFT JOIN holdings ho ON ho.investment_account_id = a.id
        WHERE a.firm_id = ?
        GROUP BY a.id, a.account_number, a.current_value
        HAVING denormalized_value != actual_value
      SQL

      # 4. Contacts without household (zero memberships)
      contacts_sql = <<~SQL
        SELECT c.id AS contact_id, c.first_name, c.last_name, c.email
        FROM contacts c
        LEFT JOIN household_memberships m ON m.contact_id = c.id
        WHERE c.firm_id = ? AND m.id IS NULL
      SQL

      # 5. Stale holdings (as_of_date older than threshold_date)
      stale_sql = <<~SQL
        SELECT ho.id AS holding_id, ho.symbol, ho.as_of_date, a.account_number,#{' '}
               c.first_name, c.last_name
        FROM holdings ho
        JOIN investment_accounts a ON ho.investment_account_id = a.id
        JOIN contacts c ON a.contact_id = c.id
        WHERE a.firm_id = ? AND ho.as_of_date < ?
      SQL

      conn = ActiveRecord::Base.connection

      {
        orphaned_accounts: conn.exec_query(ActiveRecord::Base.sanitize_sql_array([ orphaned_sql, firm_id ])),
        households_without_primary: conn.exec_query(ActiveRecord::Base.sanitize_sql_array([ households_sql, firm_id ])),
        aum_drift: conn.exec_query(ActiveRecord::Base.sanitize_sql_array([ drift_sql, firm_id ])),
        contacts_without_household: conn.exec_query(ActiveRecord::Base.sanitize_sql_array([ contacts_sql, firm_id ])),
        stale_holdings: conn.exec_query(ActiveRecord::Base.sanitize_sql_array([ stale_sql, firm_id, threshold_date ]))
      }
    end
  end
end
