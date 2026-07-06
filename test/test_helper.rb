ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup tenant helper
  def setup_default_tenant
    @firm = Firm.create!(name: "Test Wealth Advisors")
    @user = User.create!(firm: @firm, name: "Test Advisor", email: "advisor@test.com")
    Current.firm = @firm
    Current.user = @user
  end

  def authenticated_headers(firm = @firm, user = @user)
    {
      "X-Firm-Id" => firm&.id.to_s,
      "X-User-Id" => user&.id.to_s
    }
  end

  # Reset current context
  setup do
    Current.reset
  end

  teardown do
    Current.reset
  end
end
