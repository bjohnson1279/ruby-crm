# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < BaseController
    def show
      @integrity_report = Compliance::IntegrityReportQuery.call(firm_id: current_firm.id)
    end

    def integrity
      redirect_to admin_root_path
    end
  end
end
