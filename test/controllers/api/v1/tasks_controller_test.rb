require "test_helper"

module Api
  module V1
    class TasksControllerTest < ActionDispatch::IntegrationTest
      setup do
        setup_default_tenant
        @task = Tasks::Task.create!(
          assigned_user: @user,
          subject: "Initial Task",
          due_date: Date.current,
          status: "pending",
          priority: "medium"
        )
      end

      test "should get index" do
        get api_v1_tasks_url, headers: authenticated_headers(@firm, @user)
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_empty json_response["data"]
        assert_equal "Initial Task", json_response["data"].first["subject"]
      end

      test "should show task" do
        get api_v1_task_url(@task), headers: authenticated_headers(@firm, @user)
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal "Initial Task", json_response["data"]["subject"]
      end

      test "should create task" do
        assert_difference -> { Tasks::Task.count } => 1 do
          post api_v1_tasks_url,
               params: {
                 task: {
                   assigned_user_id: @user.id,
                   subject: "New Created Task",
                   due_date: Date.current,
                   priority: "low"
                 }
               },
               headers: authenticated_headers(@firm, @user),
               as: :json
          assert_response :created
        end

        json_response = JSON.parse(response.body)
        assert_equal "New Created Task", json_response["data"]["subject"]
      end

      test "should complete task" do
        post complete_api_v1_task_url(@task), headers: authenticated_headers(@firm, @user)
        assert_response :success

        @task.reload
        assert_equal "completed", @task.status
      end

      test "should filter index by status and assigned user" do
        another_user = User.create!(firm: @firm, name: "Another Advisor", email: "another@advisor.com")
        completed_task = Tasks::Task.create!(
          assigned_user: another_user,
          subject: "Completed Task",
          due_date: Date.current,
          status: "completed",
          priority: "high"
        )

        # Filter by status
        get api_v1_tasks_url(status: "completed"), headers: authenticated_headers(@firm, @user)
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response["data"].size
        assert_equal "Completed Task", json_response["data"].first["subject"]

        # Filter by assignee
        get api_v1_tasks_url(assigned_user_id: @user.id), headers: authenticated_headers(@firm, @user)
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response["data"].size
        assert_equal "Initial Task", json_response["data"].first["subject"]
      end

      test "should update task" do
        put api_v1_task_url(@task),
            params: { task: { subject: "Updated Subject" } },
            headers: authenticated_headers(@firm, @user),
            as: :json
        assert_response :success

        @task.reload
        assert_equal "Updated Subject", @task.subject
      end

      test "should return unprocessable entity on create validation failure" do
        post api_v1_tasks_url,
             params: { task: { subject: "" } },
             headers: authenticated_headers(@firm, @user),
             as: :json
        assert_response :unprocessable_entity
        json_response = JSON.parse(response.body)
        assert_includes json_response, "errors"
      end
    end
  end
end
