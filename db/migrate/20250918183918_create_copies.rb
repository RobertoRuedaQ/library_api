class CreateCopies < ActiveRecord::Migration[8.0]
  def change
    create_table :copies do |t|
      t.references :borrowable, null: false, foreign_key: true
      t.string :condition
      t.integer :status, default: 0, null: false

      t.timestamps
    end

     add_index :copies, :status
  end
end
