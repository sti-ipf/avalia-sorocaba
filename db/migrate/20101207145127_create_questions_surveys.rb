class CreateQuestionsSurveys < ActiveRecord::Migration
  def self.up
    create_table :questions_surveys, :id => false do |t|
      t.integer :question_id
      t.integer :surveys_id
    end
  end

  def self.down
    drop_table :questions_surveys
  end
end
