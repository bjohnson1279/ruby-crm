require "test_helper"

module Workflows
  class AdvanceWorkflowTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
      @contact = Contacts::Contact.create!(
        first_name: "Liam",
        last_name: "Neeson",
        email: "liam@neeson.com"
      )
      @template = Template.create!(
        name: "Standard Onboarding",
        description: "Onboard client"
      )
      @step1 = @template.template_steps.create!(
        firm: @firm,
        name: "Welcome call",
        sequence_number: 1,
        default_assigned_user: @user,
        priority: "medium",
        days_to_complete: 3
      )
      @step2 = @template.template_steps.create!(
        firm: @firm,
        name: "Risk profiling",
        sequence_number: 2,
        default_assigned_user: @user,
        priority: "medium",
        days_to_complete: 3
      )

      @process = StartWorkflow.call(
        firm: @firm,
        actor: @user,
        template: @template,
        contact: @contact,
        ip_address: "127.0.0.1"
      )
      @step1_run = @process.process_steps.find_by(workflow_template_step_id: @step1.id)
      @step2_run = @process.process_steps.find_by(workflow_template_step_id: @step2.id)
    end

    test "should complete first step, trigger advance to step 2, and complete process on last task" do
      assert_difference -> { Tasks::Task.count } => 1 do
        Tasks::CompleteTask.call(
          firm: @firm,
          actor: @user,
          task: @step1_run.task,
          ip_address: "127.0.0.1"
        )
      end

      @step1_run.reload
      @step2_run.reload
      assert_equal "completed", @step1_run.status
      assert_equal "active", @step2_run.status
      assert_not_nil @step2_run.task

      Tasks::CompleteTask.call(
        firm: @firm,
        actor: @user,
        task: @step2_run.task,
        ip_address: "127.0.0.1"
      )

      @step2_run.reload
      @process.reload
      assert_equal "completed", @step2_run.status
      assert_equal "completed", @process.status
      assert_not_nil @process.completed_at
    end
  end
end
