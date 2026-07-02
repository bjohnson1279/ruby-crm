# app/controllers/api/v1/holdings_controller.rb
module Api
  module V1
    class HoldingsController < BaseController
      before_action :set_account

      def index
        holdings = @account.holdings.order(as_of_date: :desc, symbol: :asc)
        render_json_envelope(HoldingBlueprint.render_as_hash(holdings))
      end

      def create
        holdings_params = params.permit(holdings: [:symbol, :description, :quantity, :market_value, :as_of_date])[:holdings] || []

        if holdings_params.empty?
          return render_json_error("No holdings data provided", status: :bad_request)
        end

        Accounts::ImportHoldings.call(
          firm: current_firm,
          actor: current_user,
          account: @account,
          holdings_data: holdings_params,
          ip_address: request.remote_ip
        )

        holdings = @account.holdings.reload.order(as_of_date: :desc, symbol: :asc)
        render_json_envelope(HoldingBlueprint.render_as_hash(holdings), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      private

      def set_account
        @account = Accounts::InvestmentAccount.for_firm(current_firm).find(params[:investment_account_id])
      end
    end
  end
end
