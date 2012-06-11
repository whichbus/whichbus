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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120611053145) do

  create_table "agencies", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "url"
    t.string   "timezone"
    t.string   "phone"
    t.string   "disclaimer"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "oba_id"
  end

  create_table "routes", :force => true do |t|
    t.string   "code"
    t.string   "agency_code"
    t.string   "name"
    t.string   "description"
    t.string   "route_type"
    t.string   "url"
    t.string   "color"
    t.text     "polylines"
    t.integer  "agency_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "oba_id"
  end

  create_table "routes_stops", :force => true do |t|
    t.integer "route_id"
    t.integer "stop_id"
    t.integer "index"
  end

  create_table "stops", :force => true do |t|
    t.string   "code"
    t.string   "agency_code"
    t.string   "name"
    t.string   "direction"
    t.float    "lat"
    t.float    "lon"
    t.string   "stop_type"
    t.integer  "agency_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "oba_id"
  end

end
