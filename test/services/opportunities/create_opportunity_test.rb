# test/services/opportunities/create_opportunity_test.rb
require "test_helper"

module Opportunities
  class CreateOpportunityTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should create opportunity and record audit event" do
      assert_difference -> { Opportunity.count } => 1, -> { Compliance::AuditEvent.count } => 1 do
        CreateOpportunity.call(
          firm: @firm,
          actor: @user,
          params: {
            user_id: @user.id,
            name: "New Client AUM",
            amount: 500_000.0,
            stage: "prospecting"
          },
          ip_address: "127.0.0.1"
        )
      end

      opp = Opportunity.last
      assert_equal "New Client AUM", opp.name
      assert_equal 500_000.0, opp.amount
      assert_equal 10, opp.probability

      audit = Compliance::AuditEvent.last
      assert_equal "created", audit.action
      assert_equal opp, audit.auditable
    end
  end
end
