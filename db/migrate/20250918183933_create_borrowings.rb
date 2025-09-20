class CreateBorrowings < ActiveRecord::Migration[8.0]
  def change
    create_table :borrowings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :copy, null: false, foreign_key: true
      t.datetime :borrowed_at
      t.datetime :due_at
      t.datetime :returned_at
      t.integer :renewal_count, default: 0, null: false

      t.timestamps
    end

    add_index :borrowings, :borrowed_at
    add_index :borrowings, :due_at
    add_index :borrowings, :returned_at
  end
end
