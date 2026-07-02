# app/controllers/api/v1/households_controller.rb
module Api
  module V1
    class HouseholdsController < BaseController
      def index
        households = Contacts::Household.strict_loading.for_firm(current_firm).order(:id)
        pagy, records = pagy(households)

        render_json_envelope(
          HouseholdBlueprint.render_as_hash(records, view: :summary),
          meta: pagy.data_hash
        )
      end

      def show
        household = Contacts::HouseholdDetailQuery.call(firm: current_firm, id: params[:id])
        render_json_envelope(HouseholdBlueprint.render_as_hash(household, view: :detail))
      end

      def create
        household = Contacts::CreateHousehold.call(
          firm: current_firm,
          actor: current_user,
          params: household_params,
          ip_address: request.remote_ip
        )
        render_json_envelope(HouseholdBlueprint.render_as_hash(household, view: :detail), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def update
        household = Contacts::Household.for_firm(current_firm).find(params[:id])

        ActiveRecord::Base.transaction do
          old_attrs = household.attributes.clone
          household.update!(household_params)

          Compliance::AuditLogger.record(
            firm: current_firm,
            actor: current_user,
            action: "updated",
            auditable: household,
            payload: { before: old_attrs, after: household.attributes },
            ip_address: request.remote_ip
          )
        end

        render_json_envelope(HouseholdBlueprint.render_as_hash(household, view: :detail))
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      private

      def household_params
        params.require(:household).permit(:name, :primary_contact_id)
      end
    end
  end
end
