module Api
  module V1
    class NotesController < BaseController
      def index
        relation = Contacts::Note.strict_loading.for_firm(current_firm).order(created_at: :desc, id: :desc)
        relation = relation.where(contact_id: params[:contact_id]) if params[:contact_id].present?
        relation = relation.where(household_id: params[:household_id]) if params[:household_id].present?

        pagy, records = pagy(relation)

        render_json_envelope(
          NoteBlueprint.render_as_hash(records),
          meta: pagy.data_hash
        )
      end

      def show
        note = Contacts::Note.strict_loading.for_firm(current_firm).find(params[:id])
        note.strict_loading!(false)
        render_json_envelope(NoteBlueprint.render_as_hash(note))
      end

      def create
        note = Contacts::CreateNote.call(
          firm: current_firm,
          actor: current_user,
          params: note_params,
          ip_address: request.remote_ip
        )
        note.strict_loading!(false)
        render_json_envelope(NoteBlueprint.render_as_hash(note), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      private

      def note_params
        params.require(:note).permit(:contact_id, :household_id, :body, :category)
      end
    end
  end
end
