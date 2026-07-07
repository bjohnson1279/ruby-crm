require "test_helper"

module Api
  module V1
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      setup do
        setup_default_tenant
        # Create a contact for default tenant
        @contact = Contacts::Contact.create!(
          first_name: "Bruce",
          last_name: "Wayne",
          email: "bruce@wayne.org"
        )

        # Create another tenant firm/user/contact to verify scoping isolation
        @other_firm = Firm.create!(name: "Other Wealth Advisors")
        @other_user = User.create!(firm: @other_firm, name: "Other Advisor", email: "other@firm.com")
        Current.firm = @other_firm
        Current.user = @other_user
        @other_contact = Contacts::Contact.create!(
          first_name: "Clark",
          last_name: "Kent",
          email: "clark@dailyplanet.com"
        )
        Current.reset
      end

      test "should get index containing contacts scoped to firm" do
        get api_v1_contacts_url, headers: authenticated_headers(@firm, @user)
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_includes json_response, "data"
        assert_includes json_response, "meta"

        # Should only contain Bruce, not Clark
        contacts = json_response["data"]
        assert_equal 1, contacts.size
        assert_equal "Bruce Wayne", contacts.first["name"]
      end

      test "should show contact details scoped to firm" do
        get api_v1_contact_url(@contact), headers: authenticated_headers(@firm, @user)
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal "Bruce Wayne", json_response["data"]["name"]
      end

      test "should not show contact from another firm" do
        get api_v1_contact_url(@other_contact), headers: authenticated_headers(@firm, @user)
        assert_response :not_found
      end

      test "should create contact" do
        assert_difference -> { Contacts::Contact.count } => 1 do
          post api_v1_contacts_url,
               params: {
                 contact: {
                   first_name: "Diana",
                   last_name: "Prince",
                   email: "diana@themyscira.gov"
                 }
               },
               headers: authenticated_headers(@firm, @user),
               as: :json
          assert_response :created
        end

        json_response = JSON.parse(response.body)
        assert_equal "Diana Prince", json_response["data"]["name"]
      end

      test "should return unprocessable entity on validation failure" do
        post api_v1_contacts_url,
             params: {
               contact: {
                 first_name: "",
                 last_name: "Prince",
                 email: "diana"
               }
             },
             headers: authenticated_headers(@firm, @user),
             as: :json
        assert_response :unprocessable_entity

        json_response = JSON.parse(response.body)
        assert_includes json_response, "errors"
        assert_not_empty json_response["errors"]
      end
    end
  end
end
