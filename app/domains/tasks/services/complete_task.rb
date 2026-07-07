module Tasks
  class CompleteTask
    def self.call(firm:, actor:, task:, ip_address: nil)
      ActiveRecord::Base.transaction do
        old_attrs = task.attributes.clone
        task.update!(
          status: "completed",
          completed_at: Time.current,
          completed_by: actor
        )

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "updated",
          auditable: task,
          payload: { before: old_attrs, after: task.attributes, completion: true },
          ip_address: ip_address
        )

        p_step = Workflows::ProcessStep.find_by(task_id: task.id)
        if p_step
          Workflows::AdvanceWorkflow.call(
            firm: firm,
            actor: actor,
            process_step: p_step,
            ip_address: ip_address
          )
        end

        task
      end
    end
  end
end
