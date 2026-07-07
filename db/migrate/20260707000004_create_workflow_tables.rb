class CreateWorkflowTables < ActiveRecord::Migration[8.1]
  def change
    create_table :workflow_templates do |t|
      t.references :firm, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    create_table :workflow_template_steps do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :workflow_template, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :sequence_number, null: false, default: 1
      t.references :default_assigned_user, null: false, foreign_key: { to_table: :users }
      t.string :priority, null: false, default: "medium"
      t.integer :days_to_complete, null: false, default: 3

      t.timestamps
    end

    create_table :workflow_processes do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :workflow_template, null: false, foreign_key: true
      t.references :contact, null: true, foreign_key: true
      t.references :household, null: true, foreign_key: true
      t.string :status, null: false, default: "active"
      t.datetime :started_at, null: false
      t.datetime :completed_at

      t.timestamps
    end

    add_index :workflow_processes, :status

    create_table :workflow_process_steps do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :workflow_process, null: false, foreign_key: true
      t.references :workflow_template_step, null: false, foreign_key: true
      t.references :task, null: true, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.datetime :completed_at

      t.timestamps
    end

    add_index :workflow_process_steps, :status
  end
end
