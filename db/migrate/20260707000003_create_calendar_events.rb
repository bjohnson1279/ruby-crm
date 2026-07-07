class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :contact, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.string :color, null: false, default: "blue"

      t.timestamps
    end

    add_index :calendar_events, :start_at
    add_index :calendar_events, :end_at
  end
end
