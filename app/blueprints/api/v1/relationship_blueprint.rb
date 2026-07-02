# app/blueprints/api/v1/relationship_blueprint.rb
module Api
  module V1
    class RelationshipBlueprint < Blueprinter::Base
      identifier :id
      fields :relationship_type
      association :related_contact, blueprint: Api::V1::ContactBlueprint, view: :summary
    end
  end
end
