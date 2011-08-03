# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110204020413) do

  create_table "all_answers", :id => false, :force => true do |t|
    t.integer "external_id"
    t.integer "id_instituicao"
    t.string  "numero",         :limit => 20
    t.integer "nota"
    t.date    "data"
    t.string  "level_name",     :limit => 100
    t.string  "segment_name",   :limit => 100
    t.integer "dimensao"
    t.integer "questao"
    t.integer "indicador"
    t.string  "ano",            :limit => 45
  end

  add_index "all_answers", ["data"], :name => "all_answers_data"
  add_index "all_answers", ["data"], :name => "index_all_answers_on_data"
  add_index "all_answers", ["segment_name"], :name => "index_all_answers_on_segment_name"

  create_table "answers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_id"
    t.integer  "question_id"
    t.integer  "zero"
    t.integer  "one"
    t.integer  "two"
    t.integer  "three"
    t.integer  "four"
    t.integer  "five"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participants_number"
  end

  create_table "answers_new", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_id"
    t.integer  "question_id"
    t.integer  "zero"
    t.integer  "one"
    t.integer  "two"
    t.integer  "three"
    t.integer  "four"
    t.integer  "five"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participants_number"
  end

  create_table "attendees", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comparable_answers", :force => true do |t|
    t.integer "external_id",                     :null => false
    t.integer "institution_id",                  :null => false
    t.string  "number",           :limit => 200, :null => false
    t.string  "original_number",  :limit => 200, :null => false
    t.integer "score",                           :null => false
    t.string  "level_name",       :limit => 200
    t.string  "segment_name",     :limit => 200
    t.integer "dimension",                       :null => false
    t.integer "indicator",                       :null => false
    t.integer "question",                        :null => false
    t.integer "year",                            :null => false
    t.date    "answer_date",                     :null => false
    t.string  "old_segment_name", :limit => 200
  end

  create_table "dados_2008", :id => false, :force => true do |t|
    t.integer "external_id"
    t.integer "id_instituicao"
    t.string  "numero",         :limit => 20
    t.integer "nota"
    t.date    "data"
  end

  create_table "dados_2009", :id => false, :force => true do |t|
    t.integer "external_id"
    t.integer "id_instituicao"
    t.string  "numero",         :limit => 20
    t.integer "nota"
    t.date    "data"
  end

  create_table "dimensions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forcetrue", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string "name", :limit => 250
  end

  create_table "institutions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "id_2009"
    t.integer  "id_2008"
    t.integer  "region_id"
    t.string   "group_id",   :limit => 45
  end

  create_table "institutions_service_levels", :id => false, :force => true do |t|
    t.integer "institution_id"
    t.integer "service_level_id"
  end

  create_table "questions", :force => true do |t|
    t.string   "number"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_id"
  end

  create_table "questions_surveys", :id => false, :force => true do |t|
    t.integer "question_id"
    t.integer "surveys_id"
  end

  create_table "regions", :force => true do |t|
    t.string "name", :limit => 250
  end

  create_table "report_data", :id => false, :force => true do |t|
    t.integer "institution_id",               :null => false
    t.string  "sum_type",       :limit => 50
    t.string  "item_order",     :limit => 50
    t.string  "segment_name",   :limit => 50
    t.float   "score"
    t.integer "dimension"
    t.integer "indicator"
    t.integer "question"
  end

  create_table "segments", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segments_service_levels", :id => false, :force => true do |t|
    t.integer "segment_id"
    t.integer "service_level_id"
  end

  create_table "service_levels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", :force => true do |t|
    t.integer  "segment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "service_level_id"
  end

  create_table "users", :force => true do |t|
    t.integer  "institution_id"
    t.integer  "service_level_id"
    t.integer  "segment_id"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users_new", :force => true do |t|
    t.integer  "institution_id"
    t.integer  "service_level_id"
    t.integer  "segment_id"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
