module Calendar
  class Event < ApplicationRecord
    self.table_name = "calendar_events"

    include FirmScoped

    belongs_to :user
    belongs_to :contact, class_name: "Contacts::Contact", optional: true

    COLORS = %w[blue green red yellow purple orange].freeze

    validates :title, presence: true
    validates :start_at, presence: true
    validates :end_at, presence: true
    validates :color, presence: true, inclusion: { in: COLORS }

    validate :end_at_after_start_at

    scope :overlapping_range, ->(start_date, end_date) {
      where("start_at <= ? AND end_at >= ?", end_date, start_date)
    }

    private

    def end_at_after_start_at
      return if start_at.blank? || end_at.blank?

      if end_at <= start_at
        errors.add(:end_at, "must be chronological after start_at")
      end
    end
  end
end
