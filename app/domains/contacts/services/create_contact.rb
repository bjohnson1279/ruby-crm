# app/domains/contacts/services/create_contact.rb
module Contacts
  class CreateContact
    def self.call(firm:, actor:, params:, ip_address: nil)
      ActiveRecord::Base.transaction do
        contact = Contact.new(params)
        contact.firm = firm
        contact.save!

        Compliance::AuditLogger.record(
          firm: firm,
          actor: actor,
          action: "created",
          auditable: contact,
          payload: { changes: contact.attributes },
          ip_address: ip_address
        )

        contact
      end
    end
  end
end
