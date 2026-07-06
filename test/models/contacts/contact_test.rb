require "test_helper"

module Contacts
  class ContactTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should be valid with valid attributes" do
      contact = Contact.new(
        first_name: "John",
        last_name: "Doe",
        email: "john.doe@example.com"
      )
      assert contact.valid?
    end

    test "should be invalid without first name" do
      contact = Contact.new(
        last_name: "Doe",
        email: "john.doe@example.com"
      )
      assert_not contact.valid?
      assert_includes contact.errors[:first_name], "can't be blank"
    end

    test "should be invalid without last name" do
      contact = Contact.new(
        first_name: "John",
        email: "john.doe@example.com"
      )
      assert_not contact.valid?
      assert_includes contact.errors[:last_name], "can't be blank"
    end

    test "should be invalid without email or with invalid email format" do
      contact1 = Contact.new(first_name: "John", last_name: "Doe", email: nil)
      assert_not contact1.valid?

      contact2 = Contact.new(first_name: "John", last_name: "Doe", email: "invalid-email")
      assert_not contact2.valid?
    end

    test "should automatically scope and set firm on create" do
      contact = Contact.create!(
        first_name: "Jane",
        last_name: "Doe",
        email: "jane.doe@example.com"
      )
      assert_equal @firm.id, contact.firm_id
    end
  end
end
