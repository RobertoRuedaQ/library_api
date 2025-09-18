# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_18_184840) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "author"
    t.string "genre"
    t.string "isbn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "borrowable_id", null: false
    t.index ["author"], name: "index_books_on_author"
    t.index ["borrowable_id"], name: "index_books_on_borrowable_id"
    t.index ["genre"], name: "index_books_on_genre"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
  end

  create_table "borrowables", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "item_type_id", null: false
    t.integer "copies_count", default: 0, null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type_id"], name: "index_borrowables_on_item_type_id"
    t.index ["title"], name: "index_borrowables_on_title"
    t.index ["type"], name: "index_borrowables_on_type"
  end

  create_table "borrowings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "copy_id", null: false
    t.datetime "borrowed_at"
    t.datetime "due_at"
    t.datetime "returned_at"
    t.integer "renewal_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrowed_at"], name: "index_borrowings_on_borrowed_at"
    t.index ["copy_id"], name: "index_borrowings_on_copy_id"
    t.index ["due_at"], name: "index_borrowings_on_due_at"
    t.index ["returned_at"], name: "index_borrowings_on_returned_at"
    t.index ["user_id"], name: "index_borrowings_on_user_id"
  end

  create_table "copies", force: :cascade do |t|
    t.bigint "borrowable_id", null: false
    t.string "condition"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrowable_id"], name: "index_copies_on_borrowable_id"
    t.index ["status"], name: "index_copies_on_status"
  end

  create_table "item_types", force: :cascade do |t|
    t.string "name", null: false
    t.integer "loan_duration_days", default: 1, null: false
    t.integer "max_renewals", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_item_types_on_name", unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name", null: false
    t.string "resource", null: false
    t.integer "action", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "last_name", null: false
    t.date "birth_date", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "books", "borrowables"
  add_foreign_key "borrowables", "item_types"
  add_foreign_key "borrowings", "copies"
  add_foreign_key "borrowings", "users"
  add_foreign_key "copies", "borrowables"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
