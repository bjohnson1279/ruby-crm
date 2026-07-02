# app/domains/compliance/queries/audit_timeline_query.rb
module Compliance
  class AuditTimelineQuery
    def self.call(firm:, auditable: nil, limit: 50)
      relation = AuditEvent.strict_loading
                           .for_firm(firm)
                           .includes(:actor, :auditable)
                           .order(occurred_at: :desc, id: :desc)
                           .limit(limit)

      if auditable
        relation = relation.where(auditable: auditable)
      end

      relation
    end
  end
end
