module Api
  module V1
    class CalendarFeedBlueprint < Blueprinter::Base
      identifier :id

      field :type do |obj|
        obj.is_a?(Tasks::Task) ? "task" : "event"
      end

      field :title do |obj|
        obj.is_a?(Tasks::Task) ? "Task: #{obj.subject}" : obj.title
      end

      field :description do |obj|
        obj.description
      end

      field :start_at do |obj|
        if obj.is_a?(Tasks::Task)
          obj.due_date.beginning_of_day
        else
          obj.start_at
        end
      end

      field :end_at do |obj|
        if obj.is_a?(Tasks::Task)
          obj.due_date.end_of_day
        else
          obj.end_at
        end
      end

      field :color do |obj|
        if obj.is_a?(Tasks::Task)
          case obj.priority
          when "high" then "red"
          when "medium" then "orange"
          else "blue"
          end
        else
          obj.color
        end
      end

      field :status do |obj|
        obj.is_a?(Tasks::Task) ? obj.status : nil
      end

      field :assigned_user_id do |obj|
        obj.is_a?(Tasks::Task) ? obj.assigned_user_id : obj.user_id
      end

      field :contact_id do |obj|
        obj.contact_id
      end
    end
  end
end
