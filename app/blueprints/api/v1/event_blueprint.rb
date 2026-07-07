module Api
  module V1
    class EventBlueprint < Blueprinter::Base
      identifier :id

      fields :title, :description, :start_at, :end_at, :color, :user_id, :contact_id, :created_at, :updated_at
    end
  end
end
