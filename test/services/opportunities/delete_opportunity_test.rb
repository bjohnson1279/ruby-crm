# test/services/opportunities/delete_opportunity_test.rb
require "test_helper"

module Opportunities
  class DeleteOpportunityTest < ActiveSupport::TestCase
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

    test "should delete opportunity and record audit event" do
      assert_difference -> { Opportunity.count } => -1, -> { Compliance::AuditEvent.count } => 1 do
        DeleteOpportunity.call(
          firm: @firm,
          actor: @user,
          opportunity: @opportunity,
          ip_address: "127.0.0.1"
        )
      end

      audit = Compliance::AuditEvent.last
      assert_equal "deleted", audit.action
      assert_equal "Opportunities::Opportunity", audit.auditable_type
      assert_equal "New Client AUM", audit.payload["changes"]["name"]
    end
  end
end
