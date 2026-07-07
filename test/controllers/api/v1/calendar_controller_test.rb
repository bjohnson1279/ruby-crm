require "test_helper"

module Api
  module V1
    class CalendarControllerTest < ActionDispatch::IntegrationTest
      setup do
        setup_default_tenant
        @event = Calendar::Event.create!(
          user: @user,
          title: "Standard Meeting",
          start_at: Time.current.beginning_of_day + 10.hours,
          end_at: Time.current.beginning_of_day + 11.hours,
          color: "blue"
        )
        @task = Tasks::Task.create!(
          assigned_user: @user,
          subject: "Advisory Task",
          due_date: Date.current,
          status: "pending",
          priority: "high"
        )
      end

      test "should get unified calendar feed" do
        get api_v1_calendar_index_url, headers: authenticated_headers(@firm, @user)
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_empty json_response["data"]

        feed_titles = json_response["data"].map { |item| item["title"] }
        assert_includes feed_titles, "Standard Meeting"
        assert_includes feed_titles, "Task: Advisory Task"

        meeting_event = json_response["data"].find { |item| item["type"] == "event" }
        task_event = json_response["data"].find { |item| item["type"] == "task" }

        assert_equal "blue", meeting_event["color"]
        assert_equal "red", task_event["color"]
      end

      test "should filter unified feed by user" do
        another_user = User.create!(firm: @firm, name: "Another User", email: "another@example.com")
        another_event = Calendar::Event.create!(
          user: another_user,
          title: "Secret Advisory Meeting",
          start_at: Time.current,
          end_at: 1.hour.from_now,
          color: "green"
        )

        get api_v1_calendar_index_url(user_id: another_user.id), headers: authenticated_headers(@firm, @user)
        assert_response :success

        json_response = JSON.parse(response.body)
        feed_titles = json_response["data"].map { |item| item["title"] }
        assert_includes feed_titles, "Secret Advisory Meeting"
        assert_not_includes feed_titles, "Standard Meeting"
      end

      test "should create calendar event" do
        assert_difference -> { Calendar::Event.count } => 1 do
          post api_v1_calendar_index_url,
               params: {
                 event: {
                   title: "New Created Event",
                   start_at: Time.current,
                   end_at: 1.hour.from_now,
                   color: "purple"
                 }
               },
               headers: authenticated_headers(@firm, @user),
               as: :json
          assert_response :created
        end
      end

      test "should update calendar event" do
        put api_v1_calendar_url(@event),
            params: { event: { title: "Updated Event Title" } },
            headers: authenticated_headers(@firm, @user),
            as: :json
        assert_response :success

        @event.reload
        assert_equal "Updated Event Title", @event.title
      end

      test "should delete calendar event" do
        assert_difference -> { Calendar::Event.count } => -1 do
          delete api_v1_calendar_url(@event), headers: authenticated_headers(@firm, @user)
          assert_response :success
        end
      end
    end
  end
end
