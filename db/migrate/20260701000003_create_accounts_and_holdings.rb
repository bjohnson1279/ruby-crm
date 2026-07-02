class CreateAccountsAndHoldings < ActiveRecord::Migration[8.1]
  def change
    create_table :account_types do |t|
      t.references :firm, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
    add_index :account_types, [:firm_id, :name], unique: true

    create_table :investment_accounts do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: { to_table: :contacts }
      t.references :household, null: false, foreign_key: { to_table: :households }
      t.references :account_type, null: false, foreign_key: true
      t.string :account_number, null: false
      t.string :custodian
      t.string :status, null: false, default: "active"
      t.decimal :current_value, precision: 18, scale: 2, null: false, default: 0
      t.date :as_of_date
      t.timestamps
    end
    add_index :investment_accounts, [:firm_id, :account_number], unique: true
    add_index :investment_accounts, [:firm_id, :household_id]
    add_index :investment_accounts, [:firm_id, :contact_id]

    create_table :holdings do |t|
      t.references :investment_account, null: false, foreign_key: true
      t.string :symbol, null: false
      t.string :description
      t.decimal :quantity, precision: 18, scale: 6, null: false
      t.decimal :market_value, precision: 18, scale: 2, null: false
      t.date :as_of_date, null: false
      t.timestamps
    end
    add_index :holdings, [:investment_account_id, :symbol, :as_of_date], unique: true
  end
end
