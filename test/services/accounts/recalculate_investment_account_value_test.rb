require "test_helper"

module Accounts
  class RecalculateInvestmentAccountValueTest < ActiveSupport::TestCase
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
        account_number: "ACCT-9988",
        custodian: "Schwab",
        status: "active",
        current_value: 0
      )
    end

    test "should recalculate current_value based on holdings sum" do
      # Create holdings directly without triggering service recalculation callback
      Holding.create!(
        investment_account_id: @account.id,
        symbol: "AAPL",
        description: "Apple Inc.",
        quantity: 10,
        market_value: 1800.00,
        as_of_date: Date.current
      )

      Holding.create!(
        investment_account_id: @account.id,
        symbol: "MSFT",
        description: "Microsoft Corp.",
        quantity: 5,
        market_value: 2000.00,
        as_of_date: Date.current
      )

      @account.reload
      assert_equal 0.00, @account.current_value # verify it hasn't recalculated yet

      # Execute service
      RecalculateInvestmentAccountValue.call(@account.id)

      @account.reload
      assert_equal 3800.00, @account.current_value
    end
  end
end
