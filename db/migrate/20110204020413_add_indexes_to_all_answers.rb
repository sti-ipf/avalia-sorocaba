class AddIndexesToAllAnswers < ActiveRecord::Migration
  def self.up
    add_index :all_answers, :data
    add_index :all_answers, :segment_name
  end

  def self.down
    remove_index :all_answers, :segment_name
    remove_index :all_answers, :data
  end
end