# test/controllers/api/v1/dashboard_controller_test.rb
require "test_helper"

module Api
  module V1
    class DashboardControllerTest < ActionDispatch::IntegrationTest
      setup do
        setup_default_tenant
        # Create some opportunities
        Opportunities::Opportunity.create!(
          firm: @firm,
          user: @user,
          name: "Qualified Lead",
          amount: 100_000.0,
          stage: "qualification"
        )
        Opportunities::Opportunity.create!(
          firm: @firm,
          user: @user,
          name: "Won Deal",
          amount: 250_000.0,
          stage: "closed_won" # closed won is excluded from active pipeline summary but included in stage summaries
        )
      end

      test "GET aum returns successfully" do
        get api_v1_dashboard_aum_path, headers: authenticated_headers
        assert_response :success
        json = response.parsed_body
        assert json.key?("households")
        assert json.key?("contacts")
      end

      test "GET pipeline returns aggregate opportunity metrics" do
        get api_v1_dashboard_pipeline_path, headers: authenticated_headers
        assert_response :success

        json = response.parsed_body
        # Won Deal is closed, so active pipeline metrics should only include the Qualified Lead ($100k total, 20% probability -> $20k weighted)
        assert_equal "100000.0", json["total_value"]
        assert_equal "20000.0", json["weighted_value"]
        assert_equal 1, json["opportunity_count"]

        # Check stage breakdown (includes closed deals)
        stages = json["stages"]
        assert_not_nil stages
        assert_equal 2, stages.count

        qualification_stage = stages.find { |s| s["stage"] == "qualification" }
        assert_not_nil qualification_stage
        assert_equal "100000.0", qualification_stage["total_value"]
        assert_equal 1, qualification_stage["count"]

        closed_won_stage = stages.find { |s| s["stage"] == "closed_won" }
        assert_not_nil closed_won_stage
        assert_equal "250000.0", closed_won_stage["total_value"]
        assert_equal 1, closed_won_stage["count"]
      end
    end
  end
end
