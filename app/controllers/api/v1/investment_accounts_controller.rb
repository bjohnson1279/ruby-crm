# app/controllers/api/v1/investment_accounts_controller.rb
module Api
  module V1
    class InvestmentAccountsController < BaseController
      def index
        accounts = Accounts::InvestmentAccountIndexQuery.call(
          firm: current_firm,
          status: params[:status]
        )
        pagy, records = pagy(accounts)

        render_json_envelope(
          InvestmentAccountBlueprint.render_as_hash(records, view: :summary),
          meta: pagy.data_hash
        )
      end

      def show
        account = Accounts::InvestmentAccount.strict_loading
                                              .for_firm(current_firm)
                                              .preload(:account_type, :contact, :household, :holdings)
                                              .find(params[:id])

        render_json_envelope(InvestmentAccountBlueprint.render_as_hash(account, view: :detail))
      end

      def create
        account = Accounts::CreateInvestmentAccount.call(
          firm: current_firm,
          actor: current_user,
          params: account_params,
          ip_address: request.remote_ip
        )
        render_json_envelope(InvestmentAccountBlueprint.render_as_hash(account, view: :detail), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def update
        account = Accounts::InvestmentAccount.for_firm(current_firm).find(params[:id])

        ActiveRecord::Base.transaction do
          old_attrs = account.attributes.clone
          account.update!(account_params)

          Compliance::AuditLogger.record(
            firm: current_firm,
            actor: current_user,
            action: "updated",
            auditable: account,
            payload: { before: old_attrs, after: account.attributes },
            ip_address: request.remote_ip
          )
        end

        render_json_envelope(InvestmentAccountBlueprint.render_as_hash(account, view: :detail))
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      private

      def account_params
        params.require(:investment_account).permit(
          :contact_id, :household_id, :account_type_id, 
          :account_number, :custodian, :status
        )
      end
    end
  end
end
