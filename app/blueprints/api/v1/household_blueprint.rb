# app/blueprints/api/v1/household_blueprint.rb
module Api
  module V1
    class HouseholdBlueprint < Blueprinter::Base
      identifier :id

      view :summary do
        fields :name, :primary_contact_id
      end

      view :detail do
        include_view :summary
        association :primary_contact, blueprint: Api::V1::ContactBlueprint, view: :summary
        association :household_memberships, name: :members, blueprint: Api::V1::HouseholdMembershipBlueprint
        association :investment_accounts, blueprint: Api::V1::InvestmentAccountBlueprint, view: :summary
        
        field :total_aum do |household|
          household.investment_accounts.select { |a| a.status == "active" }.sum(&:current_value)
        end

        field :account_count do |household|
          household.investment_accounts.size
        end
      end
    end
  end
end
