module Calendar
  class CreateEvent
    def self.call(firm:, actor:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        event = Event.new(params)
        event.firm = firm
        event.user = actor
        event.save!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "created",
          auditable: event,
          payload: { changes: event.attributes },
          ip_address: ip_address
        )

        event
      end
    end
  end
end
