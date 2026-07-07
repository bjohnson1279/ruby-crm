module Api
  module V1
    class WorkflowProcessesController < BaseController
      def index
        processes = Workflows::Process.strict_loading.for_firm(current_firm).includes(process_steps: :workflow_template_step)
        processes = processes.where(contact_id: params[:contact_id]) if params[:contact_id].present?
        processes = processes.where(household_id: params[:household_id]) if params[:household_id].present?

        pagy, records = pagy(processes)

        render_json_envelope(
          ProcessBlueprint.render_as_hash(records),
          meta: pagy.data_hash
        )
      end

      def show
        process = Workflows::Process.strict_loading.for_firm(current_firm).includes(process_steps: :workflow_template_step).find(params[:id])
        process.strict_loading!(false)
        process.process_steps.each do |s|
          s.strict_loading!(false)
          s.workflow_template_step.strict_loading!(false)
        end
        render_json_envelope(ProcessBlueprint.render_as_hash(process))
      end

      def create
        template = Workflows::Template.for_firm(current_firm).find(params[:workflow_template_id])
        contact = params[:contact_id].present? ? Contacts::Contact.for_firm(current_firm).find(params[:contact_id]) : nil
        household = params[:household_id].present? ? Contacts::Household.for_firm(current_firm).find(params[:household_id]) : nil

        process = Workflows::StartWorkflow.call(
          firm: current_firm,
          actor: current_user,
          template: template,
          contact: contact,
          household: household,
          ip_address: request.remote_ip
        )

        process.strict_loading!(false)
        process.process_steps.each do |s|
          s.strict_loading!(false)
          s.workflow_template_step.strict_loading!(false)
        end

        render_json_envelope(ProcessBlueprint.render_as_hash(process), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end
    end
  end
end
