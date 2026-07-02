# app/domains/contacts/models/relationship.rb
module Contacts
  class Relationship < ApplicationRecord
    self.table_name = "relationships"

    include FirmScoped

    belongs_to :contact, class_name: "Contacts::Contact"
    belongs_to :related_contact, class_name: "Contacts::Contact"

    validates :relationship_type, presence: true
    validates :related_contact_id, uniqueness: { scope: :contact_id, message: "relationship already exists" }
  end
end
