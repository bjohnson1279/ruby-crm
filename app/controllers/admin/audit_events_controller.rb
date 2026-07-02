# app/controllers/admin/audit_events_controller.rb
module Admin
  class AuditEventsController < BaseController
    def index
      events = Compliance::AuditEvent.strict_loading
                                       .for_firm(current_firm)
                                       .includes(:actor, :auditable)
                                       .order(occurred_at: :desc, id: :desc)

      events = events.where(action: params[:action_filter]) if params[:action_filter].present?
      events = events.where(auditable_type: params[:type_filter]) if params[:type_filter].present?

      @pagy, @audit_events = pagy(events, limit: 25)
    end

    def show
      @audit_event = Compliance::AuditEvent.for_firm(current_firm).find(params[:id])
    end
  end
end
