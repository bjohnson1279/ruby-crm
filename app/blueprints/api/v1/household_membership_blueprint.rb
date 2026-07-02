# app/blueprints/api/v1/household_membership_blueprint.rb
module Api
  module V1
    class HouseholdMembershipBlueprint < Blueprinter::Base
      identifier :id
      fields :role
      association :contact, blueprint: Api::V1::ContactBlueprint, view: :summary
    end
  end
end
