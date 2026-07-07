require "test_helper"

module Accounts
  class ImportHoldingsTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @contact = Contacts::Contact.create!(
        first_name: "Jane",
        last_name: "Smith",
        email: "jane.smith@example.com"
      )
      @household = Contacts::Household.create!(name: "Smith Trust")
      @account_type = AccountType.create!(name: "Traditional IRA")
      @account = InvestmentAccount.create!(
        contact: @contact,
        household: @household,
        account_type: @account_type,
        account_number: "ACCT-1122",
        custodian: "Fidelity",
        status: "active",
        current_value: 0
      )
    end

    test "should import holdings, recalculate account value, and record audit event" do
      holdings_data = [
        { symbol: "VTI", description: "Vanguard Total Stock", quantity: 10, market_value: 2500.00, as_of_date: Date.current },
        { symbol: "BND", description: "Vanguard Total Bond", quantity: 5, market_value: 500.00, as_of_date: Date.current }
      ]

      assert_difference -> { Holding.count } => 2, -> { Compliance::AuditEvent.count } => 1 do
        ImportHoldings.call(
          firm: @firm,
          actor: @user,
          account: @account,
          holdings_data: holdings_data,
          ip_address: "192.168.1.1"
        )
      end

      # Recalculated account value should be 2500.00 + 500.00 = 3000.00
      @account.reload
      assert_equal 3000.00, @account.current_value

      audit_event = Compliance::AuditEvent.includes(:auditable).last
      assert_equal "updated", audit_event.action
      assert_equal @account, audit_event.auditable
      assert_match /Bulk imported 2 holdings/, audit_event.payload["message"]
    end
  end
end
