class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :contact, null: true, foreign_key: true
      t.references :household, null: true, foreign_key: true
      t.text :body, null: false
      t.string :category, null: false

      t.timestamps
    end

    add_index :notes, :category
  end
end
