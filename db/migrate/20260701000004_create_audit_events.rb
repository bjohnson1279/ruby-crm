class CreateAuditEvents < ActiveRecord::Migration[8.1]
  def up
    create_table :audit_events do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :actor, polymorphic: true, null: false
      t.string :action, null: false
      t.references :auditable, polymorphic: true, null: false
      t.json :payload, null: false
      t.string :ip_address
      t.datetime :occurred_at, null: false
      t.datetime :created_at, null: false
    end
    add_index :audit_events, [ :firm_id, :occurred_at ]
    add_index :audit_events, [ :auditable_type, :auditable_id, :occurred_at ], name: "idx_audit_events_on_auditable"

    # Enforce database-level immutability using MySQL triggers
    safety_assured do
      execute <<~SQL
        CREATE TRIGGER prevent_audit_events_update
        BEFORE UPDATE ON audit_events
        FOR EACH ROW
        BEGIN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Audit events are immutable and cannot be updated.';
        END;
      SQL

      execute <<~SQL
        CREATE TRIGGER prevent_audit_events_delete
        BEFORE DELETE ON audit_events
        FOR EACH ROW
        BEGIN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Audit events are immutable and cannot be deleted.';
        END;
      SQL
    end
  end

  def down
    safety_assured do
      execute "DROP TRIGGER IF EXISTS prevent_audit_events_update"
      execute "DROP TRIGGER IF EXISTS prevent_audit_events_delete"
    end
    drop_table :audit_events
  end
end
