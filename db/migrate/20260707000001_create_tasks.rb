class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :assigned_user, null: false, foreign_key: { to_table: :users }
      t.references :contact, null: true, foreign_key: true
      t.string :subject, null: false
      t.text :description
      t.date :due_date, null: false
      t.string :status, null: false, default: "pending"
      t.string :priority, null: false, default: "medium"
      t.datetime :completed_at
      t.references :completed_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :due_date
  end
end
