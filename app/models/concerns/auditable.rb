# app/models/concerns/auditable.rb
module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_events, as: :auditable, class_name: "Compliance::AuditEvent"
  end
end
