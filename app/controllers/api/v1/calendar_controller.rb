module Api
  module V1
    class CalendarController < BaseController
      def index
        start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
        end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_month

        events = Calendar::Event.strict_loading
                                .for_firm(current_firm)
                                .overlapping_range(start_date.beginning_of_day, end_date.end_of_day)

        tasks = Tasks::Task.strict_loading
                           .for_firm(current_firm)
                           .where(due_date: start_date..end_date)

        if params[:user_id].present?
          events = events.where(user_id: params[:user_id])
          tasks = tasks.where(assigned_user_id: params[:user_id])
        end

        combined_feed = events.to_a + tasks.to_a
        combined_feed.each { |item| item.strict_loading!(false) }

        render_json_envelope(CalendarFeedBlueprint.render_as_hash(combined_feed))
      end

      def create
        event = Calendar::CreateEvent.call(
          firm: current_firm,
          actor: current_user,
          params: event_params,
          ip_address: request.remote_ip
        )
        event.strict_loading!(false)
        render_json_envelope(EventBlueprint.render_as_hash(event), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def update
        event = Calendar::Event.for_firm(current_firm).find(params[:id])
        Calendar::UpdateEvent.call(
          firm: current_firm,
          actor: current_user,
          event: event,
          params: event_params,
          ip_address: request.remote_ip
        )
        event.strict_loading!(false)
        render_json_envelope(EventBlueprint.render_as_hash(event))
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def destroy
        event = Calendar::Event.for_firm(current_firm).find(params[:id])
        Calendar::DeleteEvent.call(
          firm: current_firm,
          actor: current_user,
          event: event,
          ip_address: request.remote_ip
        )
        render_json_envelope({ success: true })
      end

      private

      def event_params
        params.require(:event).permit(:contact_id, :title, :description, :start_at, :end_at, :color)
      end
    end
  end
end
