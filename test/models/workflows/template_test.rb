require "test_helper"

module Workflows
  class TemplateTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should be valid with valid attributes" do
      template = Template.new(name: "Onboarding")
      assert template.valid?
    end

    test "should be invalid without name" do
      template = Template.new(name: nil)
      assert_not template.valid?
    end

    test "should automatically scope and set firm on create" do
      template = Template.create!(name: "Onboarding")
      assert_equal @firm.id, template.firm_id
    end
  end
end
