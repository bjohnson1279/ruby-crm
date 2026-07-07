require "test_helper"

module Contacts
  class CreateNoteTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @contact = Contact.create!(
        first_name: "John",
        last_name: "Smith",
        email: "john.smith@example.com"
      )
    end

    test "should create note and write audit event" do
      assert_difference -> { Note.count } => 1, -> { Compliance::AuditEvent.count } => 1 do
        CreateNote.call(
          firm: @firm,
          actor: @user,
          params: {
            contact: @contact,
            body: "Meeting with Smith family",
            category: "meeting"
          },
          ip_address: "127.0.0.1"
        )
      end

      audit_event = Compliance::AuditEvent.includes(:actor, :auditable).last
      assert_equal "created", audit_event.action
      assert_equal @user, audit_event.actor
      assert_equal "meeting", audit_event.auditable.category
    end
  end
end
