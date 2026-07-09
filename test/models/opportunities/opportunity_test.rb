# test/models/opportunities/opportunity_test.rb
require "test_helper"

module Opportunities
  class OpportunityTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should be valid with valid attributes" do
      opp = Opportunity.new(
        firm: @firm,
        user: @user,
        name: "New Client AUM",
        amount: 500_000.0,
        stage: "prospecting"
      )
      assert opp.valid?
    end

    test "should be invalid without name" do
      opp = Opportunity.new(name: nil)
      assert_not opp.valid?
    end

    test "should automatically scope and set firm on create" do
      opp = Opportunity.create!(
        user: @user,
        name: "New Client AUM",
        amount: 500_000.0,
        stage: "prospecting"
      )
      assert_equal @firm.id, opp.firm_id
    end

    test "should set default probability based on stage" do
      opp = Opportunity.create!(
        user: @user,
        name: "New Client AUM",
        amount: 500_000.0,
        stage: "prospecting"
      )
      assert_equal 10, opp.probability

      opp.update!(stage: "proposal")
      assert_equal 50, opp.probability
    end

    test "should not override probability if explicitly changed" do
      opp = Opportunity.create!(
        user: @user,
        name: "New Client AUM",
        amount: 500_000.0,
        stage: "prospecting"
      )
      opp.update!(stage: "proposal", probability: 60)
      assert_equal 60, opp.probability
    end
  end
end
