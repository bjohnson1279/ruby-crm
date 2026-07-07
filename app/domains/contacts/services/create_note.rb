module Contacts
  class CreateNote
    def self.call(firm:, actor:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        note = Note.new(params)
        note.firm = firm
        note.user = actor
        note.save!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "created",
          auditable: note,
          payload: { changes: note.attributes },
          ip_address: ip_address
        )

        note
      end
    end
  end
end
