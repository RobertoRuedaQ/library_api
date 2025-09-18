class CreateBorrowables < ActiveRecord::Migration[8.0]
  def change
    create_table :borrowables do |t|
      t.string :title, null: false
      t.references :item_type, null: false, foreign_key: true
      t.integer :copies_count, default: 0, null: false
      t.string :type, null: false
      # Specific to Book
      t.string :author
      t.string :genre
      t.string :isbn

      t.timestamps
    end

    add_index :borrowables, :title
    add_index :borrowables, :type
  end
end
