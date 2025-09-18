class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :author
      t.string :genre
      t.string :isbn

      t.timestamps
    end

    add_index :books, :author
    add_index :books, :genre
    add_index :books, :isbn, unique: true
  end
end
