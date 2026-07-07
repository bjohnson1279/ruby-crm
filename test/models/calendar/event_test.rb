require "test_helper"

module Calendar
  class EventTest < ActiveSupport::TestCase
    setup do
      setup_default_tenant
    end

    test "should be valid with valid attributes" do
      event = Event.new(
        user: @user,
        title: "Client meeting",
        start_at: Time.current,
        end_at: 1.hour.from_now,
        color: "blue"
      )
      assert event.valid?
    end

    test "should be invalid without title" do
      event = Event.new(
        user: @user,
        start_at: Time.current,
        end_at: 1.hour.from_now
      )
      assert_not event.valid?
      assert_includes event.errors[:title], "can't be blank"
    end

    test "should be invalid if end_at is before start_at" do
      event = Event.new(
        user: @user,
        title: "Client meeting",
        start_at: Time.current,
        end_at: 1.hour.ago,
        color: "blue"
      )
      assert_not event.valid?
      assert_includes event.errors[:end_at], "must be chronological after start_at"
    end

    test "should automatically scope and set firm on create" do
      event = Event.create!(
        user: @user,
        title: "Client meeting",
        start_at: Time.current,
        end_at: 1.hour.from_now,
        color: "blue"
      )
      assert_equal @firm.id, event.firm_id
    end
  end
end
