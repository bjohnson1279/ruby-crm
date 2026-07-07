module Api
  module V1
    class TemplateBlueprint < Blueprinter::Base
      identifier :id

      fields :name, :description

      association :template_steps, blueprint: Api::V1::TemplateStepBlueprint
    end
  end
end
