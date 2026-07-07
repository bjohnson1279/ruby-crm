require "test_helper"

module Contacts
  class CreateContactTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should create contact and write audit event" do
      assert_difference -> { Contact.count } => 1, -> { Compliance::AuditEvent.count } => 1 do
        contact = CreateContact.call(
          firm: @firm,
          actor: @user,
          params: {
            first_name: "Bruce",
            last_name: "Wayne",
            email: "bruce@waynecorp.com"
          },
          ip_address: "127.0.0.1"
        )

        assert_equal "Bruce", contact.first_name
        assert_equal @firm, contact.firm
      end

      audit_event = Compliance::AuditEvent.includes(:actor).last
      assert_equal "created", audit_event.action
      assert_equal @user, audit_event.actor
      assert_equal "127.0.0.1", audit_event.ip_address
    end
  end
end
