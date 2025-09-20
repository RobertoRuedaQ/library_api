class CreateItemTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :item_types do |t|
      t.string :name, null: false
      t.integer :loan_duration_days, default: 1, null: false
      t.integer :max_renewals, default: 0, null: false

      t.timestamps
    end
    add_index :item_types, :name, unique: true
  end
end
