module Api
  module V1
    class TaskBlueprint < Blueprinter::Base
      identifier :id

      view :summary do
        fields :subject, :due_date, :status, :priority
        field :assigned_user_id
        field :contact_id
      end

      view :detail do
        include_view :summary
        fields :description, :completed_at, :completed_by_id, :created_at, :updated_at
      end
    end
  end
end
