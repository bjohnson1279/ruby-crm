# app/blueprints/api/v1/audit_event_blueprint.rb
module Api
  module V1
    class AuditEventBlueprint < Blueprinter::Base
      identifier :id
      fields :action, :payload, :ip_address, :occurred_at
      
      field :actor_name do |event|
        event.actor&.name
      end

      field :auditable_type do |event|
        event.auditable_type
      end

      field :auditable_id do |event|
        event.auditable_id
      end
    end
  end
end
