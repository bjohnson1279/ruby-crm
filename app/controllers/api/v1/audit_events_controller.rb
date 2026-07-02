# app/controllers/api/v1/audit_events_controller.rb
module Api
  module V1
    class AuditEventsController < BaseController
      def index
        events = Compliance::AuditTimelineQuery.call(
          firm: current_firm,
          limit: (params[:limit] || 50).to_i
        )
        pagy, records = pagy(events)

        render_json_envelope(
          AuditEventBlueprint.render_as_hash(records),
          meta: pagy.data_hash
        )
      end
    end
  end
end
