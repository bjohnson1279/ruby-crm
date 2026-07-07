module Workflows
  class Process < ApplicationRecord
    self.table_name = "workflow_processes"

    include FirmScoped

    belongs_to :workflow_template, class_name: "Workflows::Template"
    belongs_to :contact, class_name: "Contacts::Contact", optional: true
    belongs_to :household, class_name: "Contacts::Household", optional: true
    has_many :process_steps, class_name: "Workflows::ProcessStep", foreign_key: "workflow_process_id", dependent: :destroy

    STATUSES = %w[active completed cancelled].freeze

    validates :status, presence: true, inclusion: { in: STATUSES }
    validates :started_at, presence: true
  end
end
