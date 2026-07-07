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

        task
      end
    end
  end
end
