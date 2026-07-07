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
    end
  end
end
