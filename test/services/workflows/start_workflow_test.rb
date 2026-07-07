require "test_helper"

module Workflows
  class StartWorkflowTest < ActiveSupport::TestCase
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
    end

    test "should start process, instantiate steps, and spawn first task" do
      assert_difference -> { Process.count } => 1, -> { Tasks::Task.count } => 1 do
        StartWorkflow.call(
          firm: @firm,
          actor: @user,
          template: @template,
          contact: @contact,
          ip_address: "127.0.0.1"
        )
      end

      process = Process.last
      assert_equal "active", process.status
      assert_equal 2, process.process_steps.count

      step1_run = process.process_steps.find_by(workflow_template_step_id: @step1.id)
      assert_equal "active", step1_run.status
      assert_not_nil step1_run.task

      step2_run = process.process_steps.find_by(workflow_template_step_id: @step2.id)
      assert_equal "pending", step2_run.status
      assert_nil step2_run.task
    end
  end
end
