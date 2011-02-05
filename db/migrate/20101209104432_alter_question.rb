class AlterQuestion < ActiveRecord::Migration
  def self.up
    remove_column :questions, :dimension_id
    add_column :questions, :survey_id, :integer
  end

  def self.down
    add_column :questions, :dimension_id, :integer
    remove_column :questions, :survey_id
  end
end
