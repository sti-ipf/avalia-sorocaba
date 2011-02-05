class CreateInstitutionsServiceLevels < ActiveRecord::Migration
  def self.up
    create_table :institutions_service_levels, :id => false do |t|
      t.integer :institution_id
      t.integer :service_level_id
    end
  end

  def self.down
    drop_table  :institutions_service_levels
  end
end
