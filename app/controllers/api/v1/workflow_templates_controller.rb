module Api
  module V1
    class WorkflowTemplatesController < BaseController
      def index
        templates = Workflows::Template.strict_loading.for_firm(current_firm).includes(:template_steps)
        pagy, records = pagy(templates)

        render_json_envelope(
          TemplateBlueprint.render_as_hash(records),
          meta: pagy.data_hash
        )
      end

      def show
        template = Workflows::Template.strict_loading.for_firm(current_firm).find(params[:id])
        template.strict_loading!(false)
        template.template_steps.each { |s| s.strict_loading!(false) }
        render_json_envelope(TemplateBlueprint.render_as_hash(template))
      end

      def create
        ActiveRecord::Base.transaction do
          template = Workflows::Template.new(template_params)
          template.firm = current_firm
          template.template_steps.each do |step|
            step.firm = current_firm
          end
          template.save!

          Compliance::AuditLogger.record(
            firm: current_firm,
            actor: current_user,
            action: "created",
            auditable: template,
            payload: { name: template.name },
            ip_address: request.remote_ip
          )

          template.strict_loading!(false)
          template.template_steps.each { |s| s.strict_loading!(false) }
          render_json_envelope(TemplateBlueprint.render_as_hash(template), status: :created)
        end
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      private

      def template_params
        params.require(:workflow_template).permit(
          :name, :description,
          template_steps_attributes: [ :name, :description, :sequence_number, :default_assigned_user_id, :priority, :days_to_complete ]
        )
      end
    end
  end
end
