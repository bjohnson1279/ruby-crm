require "test_helper"

module Workflows
  class ProcessTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @template = Template.create!(name: "Onboarding")
    end

    test "should be valid with valid attributes" do
      process = Process.new(
        workflow_template: @template,
        status: "active",
        started_at: Time.current
      )
      assert process.valid?
    end

    test "should automatically scope and set firm on create" do
      process = Process.create!(
        workflow_template: @template,
        status: "active",
        started_at: Time.current
      )
      assert_equal @firm.id, process.firm_id
    end
  end
end
