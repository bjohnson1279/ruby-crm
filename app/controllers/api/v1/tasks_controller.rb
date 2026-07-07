module Api
  module V1
    class TasksController < BaseController
      def index
        relation = Tasks::Task.strict_loading.for_firm(current_firm).order(due_date: :asc, id: :asc)
        relation = relation.where(status: params[:status]) if params[:status].present?
        relation = relation.where(assigned_user_id: params[:assigned_user_id]) if params[:assigned_user_id].present?
        relation = relation.where(contact_id: params[:contact_id]) if params[:contact_id].present?

        pagy, records = pagy(relation)

        render_json_envelope(
          TaskBlueprint.render_as_hash(records, view: :summary),
          meta: pagy.data_hash
        )
      end

      def show
        task = Tasks::Task.strict_loading.for_firm(current_firm).find(params[:id])
        task.strict_loading!(false)
        render_json_envelope(TaskBlueprint.render_as_hash(task, view: :detail))
      end

      def create
        task = Tasks::CreateTask.call(
          firm: current_firm,
          actor: current_user,
          params: task_params,
          ip_address: request.remote_ip
        )
        task.strict_loading!(false)
        render_json_envelope(TaskBlueprint.render_as_hash(task, view: :detail), status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def update
        task = Tasks::Task.for_firm(current_firm).find(params[:id])
        Tasks::UpdateTask.call(
          firm: current_firm,
          actor: current_user,
          task: task,
          params: task_params,
          ip_address: request.remote_ip
        )
        task.strict_loading!(false)
        render_json_envelope(TaskBlueprint.render_as_hash(task, view: :detail))
      rescue ActiveRecord::RecordInvalid => e
        render_json_errors(e.record.errors)
      end

      def complete
        task = Tasks::Task.for_firm(current_firm).find(params[:id])
        Tasks::CompleteTask.call(
          firm: current_firm,
          actor: current_user,
          task: task,
          ip_address: request.remote_ip
        )
        task.strict_loading!(false)
        render_json_envelope(TaskBlueprint.render_as_hash(task, view: :detail))
      end

      private

      def task_params
        params.require(:task).permit(:assigned_user_id, :contact_id, :subject, :description, :due_date, :status, :priority)
      end
    end
  end
end
