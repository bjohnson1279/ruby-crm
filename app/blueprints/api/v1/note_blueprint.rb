module Api
  module V1
    class NoteBlueprint < Blueprinter::Base
      identifier :id

      fields :body, :category, :user_id, :contact_id, :household_id, :created_at, :updated_at
    end
  end
end
