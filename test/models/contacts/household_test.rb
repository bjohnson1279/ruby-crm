require "test_helper"

module Contacts
  class HouseholdTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should be valid with valid attributes" do
      household = Household.new(name: "Smith Household")
      assert household.valid?
    end

    test "should be invalid without name" do
      household = Household.new(name: nil)
      assert_not household.valid?
      assert_includes household.errors[:name], "can't be blank"
    end

    test "should allow setting a primary contact" do
      contact = Contact.create!(
        first_name: "John",
        last_name: "Smith",
        email: "john.smith@example.com"
      )
      household = Household.create!(name: "Smith Household", primary_contact: contact)
      assert_equal contact, household.primary_contact
    end
  end
end
