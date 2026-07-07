module Tasks
  class UpdateTask
    def self.call(firm:, actor:, task:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        old_attrs = task.attributes.clone
        task.update!(params)

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "updated",
          auditable: task,
          payload: { before: old_attrs, after: task.attributes },
          ip_address: ip_address
        )

        task
      end
    end
  end
end
