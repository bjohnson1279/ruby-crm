module Calendar
  class UpdateEvent
    def self.call(firm:, actor:, event:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        old_attrs = event.attributes.clone
        event.update!(params)

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "updated",
          auditable: event,
          payload: { before: old_attrs, after: event.attributes },
          ip_address: ip_address
        )

        event
      end
    end
  end
end
