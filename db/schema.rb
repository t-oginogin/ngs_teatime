# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150117064413) do

  create_table "job_queues", force: :cascade do |t|
    t.integer  "job_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "command_pid"
  end

  create_table "jobs", force: :cascade do |t|
    t.string   "tool"
    t.string   "target_file_1"
    t.string   "target_file_2"
    t.string   "comment"
    t.string   "status",           default: "created"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "reference_genome"
    t.datetime "started_at"
    t.datetime "finished_at"
  end

end
