module Tasks
  class Task < ApplicationRecord
    include FirmScoped

    belongs_to :assigned_user, class_name: "User"
    belongs_to :contact, class_name: "Contacts::Contact", optional: true
    belongs_to :completed_by, class_name: "User", optional: true

    STATUSES = %w[pending completed cancelled].freeze
    PRIORITIES = %w[low medium high].freeze

    validates :subject, presence: true
    validates :due_date, presence: true
    validates :status, presence: true, inclusion: { in: STATUSES }
    validates :priority, presence: true, inclusion: { in: PRIORITIES }

    scope :pending, -> { where(status: "pending") }
    scope :completed, -> { where(status: "completed") }
    scope :overdue, -> { pending.where("due_date < ?", Date.current) }
  end
end
