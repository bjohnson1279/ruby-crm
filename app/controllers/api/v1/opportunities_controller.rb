# app/controllers/api/v1/opportunities_controller.rb
module Api
  module V1
    class OpportunitiesController < BaseController
      def index
        opportunities = Opportunities::Opportunity.strict_loading.for_firm(current_firm)
        opportunities = opportunities.where(stage: params[:stage]) if params[:stage].present?
        opportunities = opportunities.where(user_id: params[:user_id]) if params[:user_id].present?
        opportunities = opportunities.where(contact_id: params[:contact_id]) if params[:contact_id].present?

        pagy, records = pagy(opportunities)

        render_json_envelope(
          OpportunityBlueprint.render_as_hash(records, view: :summary),
          meta: pagy.data_hash
        )
      end

      def show
        opportunity = Opportunities::Opportunity.strict_loading.for_firm(current_firm).find(params[:id])
        opportunity.strict_loading!(false)
        opportunity.contact&.strict_loading!(false)
        opportunity.household&.strict_loading!(false)

        render_json_envelope(OpportunityBlueprint.render_as_hash(opportunity, view: :detail))
      end

      def create
        opportunity = Opportunities::CreateOpportunity.call(
          firm: current_firm,
          actor: current_user,
          params: opportunity_params,
          ip_address: request.remote_ip
        )
        opportunity.strict_loading!(false)

        render_json_envelope(OpportunityBlueprint.render_as_hash(opportunity, view: :summary), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def update
        opportunity = Opportunities::Opportunity.for_firm(current_firm).find(params[:id])
        Opportunities::UpdateOpportunity.call(
          firm: current_firm,
          actor: current_user,
          opportunity: opportunity,
          params: opportunity_params,
          ip_address: request.remote_ip
        )
        opportunity.strict_loading!(false)

        render_json_envelope(OpportunityBlueprint.render_as_hash(opportunity, view: :summary))
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def destroy
        opportunity = Opportunities::Opportunity.for_firm(current_firm).find(params[:id])
        Opportunities::DeleteOpportunity.call(
          firm: current_firm,
          actor: current_user,
          opportunity: opportunity,
          ip_address: request.remote_ip
        )

        render_json_envelope({ success: true })
      end

      private

      def opportunity_params
        params.require(:opportunity).permit(:user_id, :contact_id, :household_id, :name, :description, :amount, :stage, :probability, :closed_at)
      end
    end
  end
end
