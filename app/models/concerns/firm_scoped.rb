# app/models/concerns/firm_scoped.rb
module FirmScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :firm
    scope :for_firm, ->(firm) { where(firm_id: firm&.id) }

    validates :firm_id, presence: true
    before_validation :set_firm_from_current, on: :create
  end

  private

  def set_firm_from_current
    self.firm ||= Current.firm if Current.firm
  end
end
