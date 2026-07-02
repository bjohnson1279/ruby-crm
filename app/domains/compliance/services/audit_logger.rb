# app/domains/compliance/services/audit_logger.rb
module Compliance
  class AuditLogger
    def self.record(firm:, actor:, action:, auditable:, payload:, ip_address: nil)
      AuditEvent.create!(
        firm: firm,
        actor: actor,
        action: action,
        auditable: auditable,
        payload: payload,
        ip_address: ip_address,
        occurred_at: Time.current
      )
    end
  end
end
