class CreateDimensions < ActiveRecord::Migration
  def self.up
    create_table :dimensions do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :dimensions
  end
end
