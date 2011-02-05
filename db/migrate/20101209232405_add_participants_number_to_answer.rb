class AddParticipantsNumberToAnswer < ActiveRecord::Migration
  def self.up
    add_column :answers, :participants_number, :integer 
  end

  def self.down
    remove_column :answers, :participants_number
  end
end
