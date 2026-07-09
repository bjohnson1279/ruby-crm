# app/domains/opportunities/models/opportunity.rb
module Opportunities
  class Opportunity < ApplicationRecord
    self.table_name = "opportunities"

    include FirmScoped
    include Auditable

    belongs_to :user
    belongs_to :contact, class_name: "Contacts::Contact", optional: true
    belongs_to :household, class_name: "Contacts::Household", optional: true

    STAGES = %w[prospecting qualification proposal negotiation closed_won closed_lost].freeze

    STAGE_PROBABILITIES = {
      "prospecting" => 10,
      "qualification" => 20,
      "proposal" => 50,
      "negotiation" => 80,
      "closed_won" => 100,
      "closed_lost" => 0
    }.freeze

    validates :name, presence: true
    validates :stage, presence: true, inclusion: { in: STAGES }
    validates :probability, presence: true, inclusion: { in: 0..100 }
    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

    before_validation :set_default_probability, if: :will_save_change_to_stage?

    private

    def set_default_probability
      unless probability_changed?
        self.probability = STAGE_PROBABILITIES[stage] if stage.present?
      end
    end
  end
end
