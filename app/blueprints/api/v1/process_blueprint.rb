module Api
  module V1
    class ProcessBlueprint < Blueprinter::Base
      identifier :id

      fields :status, :started_at, :completed_at, :contact_id, :household_id, :workflow_template_id

      association :process_steps, blueprint: Api::V1::ProcessStepBlueprint
    end
  end
end
