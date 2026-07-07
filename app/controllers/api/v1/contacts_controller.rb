# app/controllers/api/v1/contacts_controller.rb
module Api
  module V1
    class ContactsController < BaseController
      def index
        contacts = Contacts::Contact.strict_loading.for_firm(current_firm).order(:id)
        pagy, records = pagy(contacts)

        render_json_envelope(
          ContactBlueprint.render_as_hash(records, view: :summary),
          meta: pagy.data_hash
        )
      end

      def show
        contact = Contacts::Contact.strict_loading
                                   .for_firm(current_firm)
                                   .includes(
                                     :households,
                                     relationships: :related_contact,
                                     investment_accounts: :account_type
                                   )
                                   .find(params[:id])

        render_json_envelope(ContactBlueprint.render_as_hash(contact, view: :detail))
      end

      def create
        contact = Contacts::CreateContact.call(
          firm: current_firm,
          actor: current_user,
          params: contact_params,
          ip_address: request.remote_ip
        )
        contact.strict_loading!(false)
        render_json_envelope(ContactBlueprint.render_as_hash(contact, view: :detail), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def update
        contact = Contacts::Contact.for_firm(current_firm).find(params[:id])

        ActiveRecord::Base.transaction do
          old_attrs = contact.attributes.clone
          contact.update!(contact_params)

          Compliance::AuditLogger.record(
            firm: current_firm,
            actor: current_user,
            action: "updated",
            auditable: contact,
            payload: { before: old_attrs, after: contact.attributes },
            ip_address: request.remote_ip
          )
        end

        contact.strict_loading!(false)
        render_json_envelope(ContactBlueprint.render_as_hash(contact, view: :detail))
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      private

      def contact_params
        params.require(:contact).permit(:first_name, :last_name, :email, :date_of_birth)
      end
    end
  end
end
