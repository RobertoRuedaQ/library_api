class AddBorrowableToBooks < ActiveRecord::Migration[8.0]
  def change
    add_reference :books, :borrowable, null: false, foreign_key: true
    add_index :books, :borrowable_id
  end
end
