# app/controllers/concerns/render_json_envelope.rb
module RenderJsonEnvelope
  extend ActiveSupport::Concern

  def render_json_envelope(data, meta: {}, status: :ok)
    render json: {
      data: data,
      meta: meta
    }, status: status
  end

  def render_json_error(detail, code: nil, status: :unprocessable_entity)
    render json: {
      errors: [
        {
          code: code || status.to_s,
          detail: detail
        }
      ]
    }, status: status
  end

  def render_json_errors(errors, status: :unprocessable_entity)
    # Handle ActiveModel::Errors or arrays of hashes
    formatted_errors = if errors.respond_to?(:to_hash)
      errors.to_hash(true).flat_map do |attribute, messages|
        messages.map do |msg|
          {
            code: "validation_error",
            detail: "#{attribute.to_s.humanize} #{msg}"
          }
        end
      end
    else
      Array(errors).map do |err|
        if err.is_a?(Hash)
          { code: err[:code] || "error", detail: err[:detail] }
        else
          { code: "error", detail: err.to_s }
        end
      end
    end

    render json: { errors: formatted_errors }, status: status
  end
end
