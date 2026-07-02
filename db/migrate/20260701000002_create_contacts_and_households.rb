class CreateContactsAndHouseholds < ActiveRecord::Migration[8.1]
  def change
    create_table :households do |t|
      t.references :firm, null: false, foreign_key: true
      t.string :name, null: false
      t.bigint :primary_contact_id
      t.timestamps
    end

    create_table :contacts do |t|
      t.references :firm, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.date :date_of_birth
      t.timestamps
    end
    add_index :contacts, [:firm_id, :email]

    # Add foreign key from households to contacts for primary contact link
    safety_assured do
      add_foreign_key :households, :contacts, column: :primary_contact_id
    end

    create_table :household_memberships do |t|
      t.references :household, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.string :role, null: false, default: "member"
      t.timestamps
    end
    add_index :household_memberships, [:household_id, :contact_id], unique: true

    create_table :relationships do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: { to_table: :contacts }
      t.references :related_contact, null: false, foreign_key: { to_table: :contacts }
      t.string :relationship_type, null: false
      t.timestamps
    end
    add_index :relationships, [:contact_id, :related_contact_id], unique: true
  end
end
