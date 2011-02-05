class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :institution_id
      t.integer :service_level_id
      t.integer :segment_id
      t.string :password

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
