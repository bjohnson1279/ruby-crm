# app/domains/compliance/models/audit_event.rb
module Compliance
  class AuditEvent < ApplicationRecord
    self.table_name = "audit_events"

    include FirmScoped

    belongs_to :actor, polymorphic: true
    belongs_to :auditable, polymorphic: true

    validates :action, presence: true
    validates :payload, presence: true
    validates :occurred_at, presence: true

    # Make the audit log immutable in Rails after creation
    def readonly?
      persisted?
    end

    # Block destroy/delete at ActiveRecord layer as well
    def destroy
      raise ActiveRecord::ReadOnlyRecord, "Audit events are immutable and cannot be deleted."
    end

    def delete
      raise ActiveRecord::ReadOnlyRecord, "Audit events are immutable and cannot be deleted."
    end
  end
end
