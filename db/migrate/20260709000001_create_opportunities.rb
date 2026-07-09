class CreateOpportunities < ActiveRecord::Migration[8.1]
  def change
    create_table :opportunities do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :contact, null: true, foreign_key: true
      t.references :household, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :amount, precision: 18, scale: 2, null: false, default: 0.0
      t.string :stage, null: false, default: "prospecting"
      t.integer :probability, null: false, default: 10
      t.date :closed_at

      t.timestamps
    end

    add_index :opportunities, :stage
  end
end
