# app/blueprints/api/v1/contact_blueprint.rb
module Api
  module V1
    class ContactBlueprint < Blueprinter::Base
      identifier :id

      view :summary do
        fields :first_name, :last_name, :email, :date_of_birth
        field :name do |contact|
          contact.name
        end
      end

      view :detail do
        include_view :summary
        association :households, blueprint: Api::V1::HouseholdBlueprint, view: :summary
        association :relationships, blueprint: Api::V1::RelationshipBlueprint
        association :investment_accounts, blueprint: Api::V1::InvestmentAccountBlueprint, view: :summary
      end
    end
  end
end
