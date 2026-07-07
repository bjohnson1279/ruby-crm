module Workflows
  class ProcessStep < ApplicationRecord
    self.table_name = "workflow_process_steps"

    include FirmScoped

    belongs_to :workflow_process, class_name: "Workflows::Process"
    belongs_to :workflow_template_step, class_name: "Workflows::TemplateStep"
    belongs_to :task, class_name: "Tasks::Task", optional: true

    STATUSES = %w[pending active completed skipped].freeze

    validates :status, presence: true, inclusion: { in: STATUSES }
  end
end
