class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name

      t.timestamps
    end
    groups = ["Progresso", "Oeste 1", "Oeste 2", "Oeste 3", "Aparecidinha", "Brigadeiro", "Norte Ipa ", "Norte Ita 1", "Norte Ita 2", "Norte Ita 3", "Central", "Leste", "Éden/Cajuru", "Leste 2"]
    groups.each do |group|
      Group.create(:name => group)
    end
  end

  def self.down
    drop_table :groups
  end
end
