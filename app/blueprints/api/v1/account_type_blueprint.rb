# app/blueprints/api/v1/account_type_blueprint.rb
module Api
  module V1
    class AccountTypeBlueprint < Blueprinter::Base
      identifier :id
      fields :name
    end
  end
end
