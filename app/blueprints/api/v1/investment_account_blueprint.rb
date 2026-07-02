# app/blueprints/api/v1/investment_account_blueprint.rb
module Api
  module V1
    class InvestmentAccountBlueprint < Blueprinter::Base
      identifier :id

      view :summary do
        fields :account_number, :custodian, :status, :current_value, :as_of_date
        field :owner_contact_id do |account|
          account.contact_id
        end
        field :household_id do |account|
          account.household_id
        end
      end

      view :detail do
        include_view :summary
        association :account_type, blueprint: Api::V1::AccountTypeBlueprint
        association :contact, blueprint: Api::V1::ContactBlueprint, view: :summary
        association :household, blueprint: Api::V1::HouseholdBlueprint, view: :summary
        association :holdings, blueprint: Api::V1::HoldingBlueprint
      end
    end
  end
end
