module Workflows
  class TemplateStep < ApplicationRecord
    self.table_name = "workflow_template_steps"

    include FirmScoped

    belongs_to :workflow_template, class_name: "Workflows::Template"
    belongs_to :default_assigned_user, class_name: "User"

    PRIORITIES = %w[low medium high].freeze

    validates :name, presence: true
    validates :sequence_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
    validates :priority, presence: true, inclusion: { in: PRIORITIES }
    validates :days_to_complete, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end
end
