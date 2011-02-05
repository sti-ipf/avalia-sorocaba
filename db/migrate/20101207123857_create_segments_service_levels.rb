class CreateSegmentsServiceLevels < ActiveRecord::Migration
  def self.up
    create_table :segments_service_levels, :id => false do |t|
      t.integer :segment_id
      t.integer :service_level_id
    end
  end

  def self.down
    drop_table :segments_service_levels
  end
end
