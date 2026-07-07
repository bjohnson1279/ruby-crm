require "test_helper"

module Tasks
  class CompleteTaskTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @task = Task.create!(
        assigned_user: @user,
        subject: "Process forms",
        due_date: Date.current,
        status: "pending",
        priority: "medium"
      )
    end

    test "should complete task and write audit event" do
      assert_difference -> { Compliance::AuditEvent.count } => 1 do
        CompleteTask.call(
          firm: @firm,
          actor: @user,
          task: @task,
          ip_address: "127.0.0.1"
        )
      end

      @task.reload
      assert_equal "completed", @task.status
      assert_not_nil @task.completed_at
      assert_equal @user, @task.completed_by

      audit_event = Compliance::AuditEvent.includes(:actor, :auditable).last
      assert_equal "updated", audit_event.action
      assert_equal @user, audit_event.actor
      assert_equal @task, audit_event.auditable
    end
  end
end
