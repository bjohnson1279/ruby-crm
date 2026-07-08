module Workflows
  class AdvanceWorkflow
    def self.call(firm:, actor:, process_step:, ip_address: nil)
      process_step.strict_loading!(false)
      process_step.workflow_template_step&.strict_loading!(false)

      ActiveRecord::Base.transaction do
        process_step.update!(
          status: "completed",
          completed_at: Time.current
        )

        process = process_step.workflow_process
        process.strict_loading!(false)

        current_sequence = process_step.workflow_template_step.sequence_number

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "updated",
          auditable: process_step,
          payload: { step_name: process_step.workflow_template_step.name, status: "completed" },
          ip_address: ip_address
        )

        any_incomplete = process.process_steps.joins(:workflow_template_step)
                                .where("workflow_template_steps.sequence_number <= ?", current_sequence)
                                .where.not(status: "completed")
                                .exists?

        unless any_incomplete
          next_steps = process.process_steps.joins(:workflow_template_step)
                              .where(workflow_template_steps: { sequence_number: current_sequence + 1 })

          if next_steps.exists?
            next_steps.each do |p_step|
              p_step.strict_loading!(false)
              t_step = p_step.workflow_template_step
              t_step.strict_loading!(false)

              task = Tasks::CreateTask.call(
                firm: firm,
                actor: actor,
                params: {
                  assigned_user: t_step.default_assigned_user,
                  contact: process.contact,
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
          else
            total_incomplete = process.process_steps.where.not(status: "completed").exists?
            unless total_incomplete
              process.update!(
                status: "completed",
                completed_at: Time.current
              )

              Compliance::AuditLogger.record(
                firm: firm,
                actor: actor,
                action: "updated",
                auditable: process,
                payload: { status: "completed", completed_at: process.completed_at },
                ip_address: ip_address
              )
            end
          end
        end

        process
      end
    end
  end
end
