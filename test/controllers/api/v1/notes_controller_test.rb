require "test_helper"

module Api
  module V1
    class NotesControllerTest < ActionDispatch::IntegrationTest
      setup do
        setup_default_tenant
        @contact = Contacts::Contact.create!(
          first_name: "John",
          last_name: "Smith",
          email: "john.smith@example.com"
        )
        @note = Contacts::Note.create!(
          user: @user,
          contact: @contact,
          body: "Initial note",
          category: "call"
        )
      end

      test "should get index" do
        get api_v1_notes_url, headers: authenticated_headers(@firm, @user)
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_empty json_response["data"]
        assert_equal "Initial note", json_response["data"].first["body"]
      end

      test "should show note" do
        get api_v1_note_url(@note), headers: authenticated_headers(@firm, @user)
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal "Initial note", json_response["data"]["body"]
      end

      test "should create note" do
        assert_difference -> { Contacts::Note.count } => 1 do
          post api_v1_notes_url,
               params: {
                 note: {
                   contact_id: @contact.id,
                   body: "New Created Note",
                   category: "meeting"
                 }
               },
               headers: authenticated_headers(@firm, @user),
               as: :json
          assert_response :created
        end

        json_response = JSON.parse(response.body)
        assert_equal "New Created Note", json_response["data"]["body"]
      end

      test "should filter index by contact" do
        another_contact = Contacts::Contact.create!(
          first_name: "Jane",
          last_name: "Doe",
          email: "jane.doe@example.com"
        )
        another_note = Contacts::Note.create!(
          user: @user,
          contact: another_contact,
          body: "Another note",
          category: "meeting"
        )

        get api_v1_notes_url(contact_id: another_contact.id), headers: authenticated_headers(@firm, @user)
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response["data"].size
        assert_equal "Another note", json_response["data"].first["body"]
      end

      test "should return unprocessable entity on create validation failure" do
        post api_v1_notes_url,
             params: { note: { body: "" } },
             headers: authenticated_headers(@firm, @user),
             as: :json
        assert_response :unprocessable_entity
        json_response = JSON.parse(response.body)
        assert_includes json_response, "errors"
      end
    end
  end
end
