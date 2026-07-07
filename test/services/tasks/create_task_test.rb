require "test_helper"

module Tasks
  class CreateTaskTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should create task and write audit event" do
      assert_difference -> { Task.count } => 1, -> { Compliance::AuditEvent.count } => 1 do
        CreateTask.call(
          firm: @firm,
          actor: @user,
          params: {
            assigned_user: @user,
            subject: "Verify tax logs",
            due_date: Date.current,
            status: "pending",
            priority: "medium"
          },
          ip_address: "127.0.0.1"
        )
      end

      audit_event = Compliance::AuditEvent.includes(:actor, :auditable).last
      assert_equal "created", audit_event.action
      assert_equal @user, audit_event.actor
      assert_equal "Verify tax logs", audit_event.auditable.subject
    end
  end
end
