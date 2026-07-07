require "test_helper"

module Contacts
  class NoteTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @contact = Contact.create!(
        first_name: "John",
        last_name: "Smith",
        email: "john.smith@example.com"
      )
    end

    test "should be valid with valid attributes" do
      note = Note.new(
        user: @user,
        contact: @contact,
        body: "Spoke with client.",
        category: "call"
      )
      assert note.valid?
    end

    test "should be invalid without body" do
      note = Note.new(
        user: @user,
        category: "call"
      )
      assert_not note.valid?
      assert_includes note.errors[:body], "can't be blank"
    end

    test "should be invalid with invalid category" do
      note = Note.new(
        user: @user,
        body: "Spoke with client.",
        category: "invalid-cat"
      )
      assert_not note.valid?
      assert_includes note.errors[:category], "is not included in the list"
    end

    test "should automatically scope and set firm on create" do
      note = Note.create!(
        user: @user,
        body: "Spoke with client.",
        category: "call"
      )
      assert_equal @firm.id, note.firm_id
    end
  end
end
