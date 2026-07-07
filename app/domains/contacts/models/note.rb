module Contacts
  class Note < ApplicationRecord
    include FirmScoped

    belongs_to :user
    belongs_to :contact, optional: true
    belongs_to :household, optional: true

    CATEGORIES = %w[call email meeting review general].freeze

    validates :body, presence: true
    validates :category, presence: true, inclusion: { in: CATEGORIES }
  end
end
