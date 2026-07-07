module Api
  module V1
    class TemplateStepBlueprint < Blueprinter::Base
      identifier :id

      fields :name, :description, :sequence_number, :default_assigned_user_id, :priority, :days_to_complete
    end
  end
end
