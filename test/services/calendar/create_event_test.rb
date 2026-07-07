require "test_helper"

module Calendar
  class CreateEventTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should create calendar event and log audit event" do
      assert_difference -> { Event.count } => 1, -> { Compliance::AuditEvent.count } => 1 do
        CreateEvent.call(
          firm: @firm,
          actor: @user,
          params: {
            title: "Q3 Review Session",
            start_at: Time.current,
            end_at: 2.hours.from_now,
            color: "green"
          },
          ip_address: "127.0.0.1"
        )
      end

      audit_event = Compliance::AuditEvent.includes(:actor, :auditable).last
      assert_equal "created", audit_event.action
      assert_equal @user, audit_event.actor
      assert_equal "Q3 Review Session", audit_event.auditable.title
    end
  end
end
