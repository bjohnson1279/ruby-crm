require "test_helper"

module Calendar
  class DeleteEventTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @event = Event.create!(
        user: @user,
        title: "To Be Deleted",
        start_at: Time.current,
        end_at: 1.hour.from_now,
        color: "blue"
      )
    end

    test "should delete event and log audit event" do
      assert_difference -> { Event.count } => -1, -> { Compliance::AuditEvent.count } => 1 do
        DeleteEvent.call(
          firm: @firm,
          actor: @user,
          event: @event,
          ip_address: "127.0.0.1"
        )
      end

      audit_event = Compliance::AuditEvent.includes(:actor).last
      assert_equal "deleted", audit_event.action
      assert_equal @user, audit_event.actor
      assert_equal "To Be Deleted", audit_event.payload["changes"]["title"]
    end
  end
end
