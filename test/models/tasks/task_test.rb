require "test_helper"

module Tasks
  class TaskTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should be valid with valid attributes" do
      task = Task.new(
        assigned_user: @user,
        subject: "Follow up call",
        due_date: Date.current,
        status: "pending",
        priority: "medium"
      )
      assert task.valid?
    end

    test "should be invalid without subject" do
      task = Task.new(
        assigned_user: @user,
        due_date: Date.current
      )
      assert_not task.valid?
      assert_includes task.errors[:subject], "can't be blank"
    end

    test "should be invalid without due date" do
      task = Task.new(
        assigned_user: @user,
        subject: "Follow up call"
      )
      assert_not task.valid?
      assert_includes task.errors[:due_date], "can't be blank"
    end

    test "should automatically scope and set firm on create" do
      task = Task.create!(
        assigned_user: @user,
        subject: "Follow up call",
        due_date: Date.current
      )
      assert_equal @firm.id, task.firm_id
    end
  end
end
