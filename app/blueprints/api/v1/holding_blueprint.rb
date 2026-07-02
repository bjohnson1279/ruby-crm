# app/blueprints/api/v1/holding_blueprint.rb
module Api
  module V1
    class HoldingBlueprint < Blueprinter::Base
      identifier :id
      fields :symbol, :description, :quantity, :market_value, :as_of_date
    end
  end
end
