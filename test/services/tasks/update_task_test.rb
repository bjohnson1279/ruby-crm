require "test_helper"

module Tasks
  class UpdateTaskTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @task = Task.create!(
        assigned_user: @user,
        subject: "Old Subject",
        due_date: Date.current,
        status: "pending",
        priority: "medium"
      )
    end

    test "should update task and log audit event changes" do
      assert_difference -> { Compliance::AuditEvent.count } => 1 do
        UpdateTask.call(
          firm: @firm,
          actor: @user,
          task: @task,
          params: { subject: "New Subject", priority: "high" },
          ip_address: "127.0.0.1"
        )
      end

      @task.reload
      assert_equal "New Subject", @task.subject
      assert_equal "high", @task.priority

      audit_event = Compliance::AuditEvent.includes(:actor, :auditable).last
      assert_equal "updated", audit_event.action
      assert_equal @user, audit_event.actor
      assert_equal "Old Subject", audit_event.payload["before"]["subject"]
      assert_equal "New Subject", audit_event.payload["after"]["subject"]
    end
  end
end
