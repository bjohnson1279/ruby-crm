# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      include RenderJsonEnvelope
      include Pagy::Backend

      before_action :authenticate_and_set_context

      private

      def authenticate_and_set_context
        firm_id = request.headers["X-Firm-Id"]
        user_id = request.headers["X-User-Id"]

        if firm_id.present?
          Current.firm = Firm.find_by(id: firm_id)
        end

        if user_id.present?
          Current.user = User.find_by(id: user_id)
        end

        # Phase 1: development/test fallback
        if (Rails.env.development? || Rails.env.test?) && (Current.firm.nil? || Current.user.nil?)
          Current.firm ||= Firm.first
          Current.user ||= User.first
        end

        if Current.firm.nil? || Current.user.nil?
          render_json_error("Unauthorized: Please provide valid X-Firm-Id and X-User-Id headers.", code: "unauthorized", status: :unauthorized)
        end
      end

      def current_firm
        Current.firm
      end

      def current_user
        Current.user
      end
    end
  end
end
