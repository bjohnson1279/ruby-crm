# app/controllers/api/v1/dashboard_controller.rb
module Api
  module V1
    class DashboardController < BaseController
      def aum
        limit = (params[:limit] || 25).to_i

        households_aum = Accounts::AumByHouseholdQuery.call(firm_id: current_firm.id, limit: limit)
        contacts_aum = Accounts::AumByContactQuery.call(firm_id: current_firm.id, limit: limit)

        formatted_households = households_aum.map do |res|
          {
            household_id: res.household_id,
            name: res.name,
            total_aum: res.total_aum.to_s,
            account_count: res.account_count
          }
        end

        formatted_contacts = contacts_aum.map do |res|
          {
            contact_id: res.contact_id,
            first_name: res.first_name,
            last_name: res.last_name,
            total_aum: res.total_aum.to_s,
            account_count: res.account_count
          }
        end

        render_json_envelope({
          households: formatted_households,
          contacts: formatted_contacts
        })
      end

      def pipeline
        summary = Opportunities::PipelineSummaryQuery.call(firm_id: current_firm.id)

        render_json_envelope({
          total_value: summary.total_value.to_s,
          weighted_value: summary.weighted_value.to_s,
          opportunity_count: summary.opportunity_count,
          stages: summary.stages.map { |s| { stage: s.stage, total_value: s.total_value.to_s, weighted_value: s.weighted_value.to_s, count: s.count } },
          advisors: summary.advisors.map { |a| { user_id: a.user_id, user_name: a.user_name, total_value: a.total_value.to_s, weighted_value: a.weighted_value.to_s, count: a.count } }
        })
      end
    end
  end
end
