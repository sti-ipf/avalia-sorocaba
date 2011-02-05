class AddServiceLevelToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :service_level_id, :integer
  end

  def self.down
    remove_column :surveys, :service_level_id
  end
end
