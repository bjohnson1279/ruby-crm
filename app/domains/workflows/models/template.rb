module Workflows
  class Template < ApplicationRecord
    self.table_name = "workflow_templates"

    include FirmScoped

    has_many :template_steps, class_name: "Workflows::TemplateStep", foreign_key: "workflow_template_id", dependent: :destroy
    accepts_nested_attributes_for :template_steps

    validates :name, presence: true
  end
end
