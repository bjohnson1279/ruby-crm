module Calendar
  class DeleteEvent
    def self.call(firm:, actor:, event:, ip_address: nil)
      ActiveRecord::Base.transaction do
        old_attrs = event.attributes.clone
        event.destroy!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "deleted",
          auditable: event,
          payload: { changes: old_attrs },
          ip_address: ip_address
        )

        event
      end
    end
  end
end
