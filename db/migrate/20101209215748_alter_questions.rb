class AlterQuestions < ActiveRecord::Migration
  def self.up
    change_column :questions, :number, :string
  end

  def self.down
    change_column :questions, :number, :integer
  end
end
