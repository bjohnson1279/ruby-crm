module Tasks
  class CreateTask
    def self.call(firm:, actor:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        task = Task.new(params)
        task.firm = firm
        task.save!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "created",
          auditable: task,
          payload: { changes: task.attributes },
          ip_address: ip_address
        )

        task
      end
    end
  end
end
