# app/controllers/admin/base_controller.rb
module Admin
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :set_context

    layout "admin"

    private

    def set_context
      Current.firm = Firm.first
      Current.user = User.first

      if Current.firm.nil? || Current.user.nil?
        render plain: "Unauthorized: Please run db:seed to create baseline firm/user before accessing admin.", status: :unauthorized
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
