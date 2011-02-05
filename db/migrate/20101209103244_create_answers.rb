class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer :user_id
      t.integer :survey_id
      t.integer :question_id
      t.integer :zero
      t.integer :one
      t.integer :two
      t.integer :three
      t.integer :four
      t.integer :five

      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
