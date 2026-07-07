module Api
  module V1
    class ProcessStepBlueprint < Blueprinter::Base
      identifier :id

      fields :status, :completed_at, :task_id, :workflow_template_step_id

      association :workflow_template_step, blueprint: Api::V1::TemplateStepBlueprint
    end
  end
end
