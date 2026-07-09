# test/controllers/api/v1/opportunities_controller_test.rb
require "test_helper"

module Api
  module V1
    class OpportunitiesControllerTest < ActionDispatch::IntegrationTest
      setup do
        setup_default_tenant
        @opportunity = Opportunities::Opportunity.create!(
          firm: @firm,
          user: @user,
          name: "Active Lead",
          amount: 150_000.0,
          stage: "qualification"
        )
      end

      test "GET index returns scaled list of opportunities" do
        get api_v1_opportunities_path, headers: authenticated_headers
        assert_response :success

        json = response.parsed_body
        assert_equal 1, json["data"].count
        assert_equal "Active Lead", json["data"].first["name"]
      end

      test "GET show returns detail for opportunity" do
        get api_v1_opportunity_path(@opportunity), headers: authenticated_headers
        assert_response :success

        json = response.parsed_body
        assert_equal "Active Lead", json["data"]["name"]
      end

      test "POST create instantiates a new opportunity" do
        assert_difference -> { Opportunities::Opportunity.count } => 1 do
          post api_v1_opportunities_path,
               params: {
                 opportunity: {
                   user_id: @user.id,
                   name: "New Pipeline Deal",
                   amount: 300_000.0,
                   stage: "proposal"
                 }
               },
               headers: authenticated_headers
          assert_response :created
        end

        json = response.parsed_body
        assert_equal "New Pipeline Deal", json["data"]["name"]
        assert_equal 50, json["data"]["probability"] # stage default
      end

      test "PATCH update edits opportunity features" do
        patch api_v1_opportunity_path(@opportunity),
              params: {
                opportunity: {
                  stage: "negotiation"
                }
              },
              headers: authenticated_headers
        assert_response :success

        @opportunity.reload
        assert_equal "negotiation", @opportunity.stage
        assert_equal 80, @opportunity.probability
      end

      test "DELETE destroy removes opportunity" do
        assert_difference -> { Opportunities::Opportunity.count } => -1 do
          delete api_v1_opportunity_path(@opportunity), headers: authenticated_headers
          assert_response :success
        end
      end
    end
  end
end
