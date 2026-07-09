# app/blueprints/api/v1/opportunity_blueprint.rb
module Api
  module V1
    class OpportunityBlueprint < Blueprinter::Base
      identifier :id

      view :summary do
        fields :name, :description, :amount, :stage, :probability, :closed_at, :user_id, :contact_id, :household_id, :created_at, :updated_at
      end

      view :detail do
        include_view :summary
        association :contact, blueprint: Api::V1::ContactBlueprint, view: :summary
        association :household, blueprint: Api::V1::HouseholdBlueprint, view: :summary
      end
    end
  end
end
