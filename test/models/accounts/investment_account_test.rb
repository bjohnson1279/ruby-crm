require "test_helper"

module Accounts
  class InvestmentAccountTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @contact = Contacts::Contact.create!(
        first_name: "Jane",
        last_name: "Smith",
        email: "jane.smith@example.com"
      )
      @household = Contacts::Household.create!(name: "Smith Trust")
      @account_type = AccountType.create!(name: "Traditional IRA")
    end

    test "should be valid with valid attributes" do
      account = InvestmentAccount.new(
        contact: @contact,
        household: @household,
        account_type: @account_type,
        account_number: "ACCT-12345",
        custodian: "Fidelity",
        status: "active",
        current_value: 10000.00
      )
      assert account.valid?
    end

    test "should enforce uniqueness of account number scoped to firm_id" do
      acc1 = InvestmentAccount.create!(
        contact: @contact,
        household: @household,
        account_type: @account_type,
        account_number: "ACCT-12345",
        custodian: "Fidelity",
        status: "active",
        current_value: 0
      )

      acc2 = InvestmentAccount.new(
        contact: @contact,
        household: @household,
        account_type: @account_type,
        account_number: "ACCT-12345",
        custodian: "Schwab",
        status: "active",
        current_value: 0
      )

      assert_not acc2.valid?
      assert_includes acc2.errors[:account_number], "already exists for this firm"
    end
  end
end
