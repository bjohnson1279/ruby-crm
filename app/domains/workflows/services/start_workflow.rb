module Workflows
  class StartWorkflow
    def self.call(firm:, actor:, template:, contact: nil, household: nil, ip_address: nil)
      ActiveRecord::Base.transaction do
        process = Process.create!(
          firm: firm,
          workflow_template: template,
          contact: contact,
          household: household,
          status: "active",
          started_at: Time.current
        )

        template.template_steps.order(sequence_number: :asc, id: :asc).each do |t_step|
          process.process_steps.create!(
            firm: firm,
            workflow_template_step: t_step,
            status: "pending"
          )
        end

        first_steps = process.process_steps.joins(:workflow_template_step)
                             .where(workflow_template_steps: { sequence_number: 1 })

        first_steps.each do |p_step|
          t_step = p_step.workflow_template_step

          task = Tasks::CreateTask.call(
            firm: firm,
            actor: actor,
            params: {
              assigned_user: t_step.default_assigned_user,
              contact: contact,
              subject: t_step.name,
              description: t_step.description,
              due_date: Date.current + t_step.days_to_complete,
              status: "pending",
              priority: t_step.priority
            },
            ip_address: ip_address
          )

          p_step.update!(status: "active", task: task)
        end

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "created",
          auditable: process,
          payload: { started_by_id: actor.id, contact_id: contact&.id, household_id: household&.id },
          ip_address: ip_address
        )

        process
      end
    end
  end
end
