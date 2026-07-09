# test/services/opportunities/update_opportunity_test.rb
require "test_helper"

module Opportunities
  class UpdateOpportunityTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @opportunity = Opportunity.create!(
        firm: @firm,
        user: @user,
        name: "New Client AUM",
        amount: 500_000.0,
        stage: "prospecting"
      )
    end

    test "should update opportunity and record audit event" do
      assert_difference -> { Compliance::AuditEvent.count } => 1 do
        UpdateOpportunity.call(
          firm: @firm,
          actor: @user,
          opportunity: @opportunity,
          params: {
            stage: "proposal",
            amount: 600_000.0
          },
          ip_address: "127.0.0.1"
        )
      end

      @opportunity.reload
      assert_equal "proposal", @opportunity.stage
      assert_equal 600_000.0, @opportunity.amount
      assert_equal 50, @opportunity.probability # Stage default callback

      audit = Compliance::AuditEvent.includes(:auditable).last
      assert_equal "updated", audit.action
      assert_equal @opportunity, audit.auditable
      assert_equal 500_000.0, BigDecimal(audit.payload["before"]["amount"].to_s)
      assert_equal 600_000.0, BigDecimal(audit.payload["after"]["amount"].to_s)
    end
  end
end
