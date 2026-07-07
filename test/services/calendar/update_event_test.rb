require "test_helper"

module Calendar
  class UpdateEventTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @event = Event.create!(
        user: @user,
        title: "Old Title",
        start_at: Time.current,
        end_at: 1.hour.from_now,
        color: "blue"
      )
    end

    test "should update calendar event and log audit event changes" do
      assert_difference -> { Compliance::AuditEvent.count } => 1 do
        UpdateEvent.call(
          firm: @firm,
          actor: @user,
          event: @event,
          params: { title: "New Title", color: "red" },
          ip_address: "127.0.0.1"
        )
      end

      @event.reload
      assert_equal "New Title", @event.title
      assert_equal "red", @event.color

      audit_event = Compliance::AuditEvent.includes(:actor, :auditable).last
      assert_equal "updated", audit_event.action
      assert_equal @user, audit_event.actor
      assert_equal "Old Title", audit_event.payload["before"]["title"]
      assert_equal "New Title", audit_event.payload["after"]["title"]
    end
  end
end
