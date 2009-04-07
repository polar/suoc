class AddUserClubAffiliation < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.references :club_affiliation
    end
  end

  def self.down
    change_table :users do |t|
      t.remove_references :club_affiliation
    end
  end
end
