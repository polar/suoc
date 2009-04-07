class CreateClubAffiliations < ActiveRecord::Migration
  def self.up
    create_table :club_affiliations do |t|
      t.string     :name
      t.string     :description, :default => ""

      t.timestamps
    end
  end

  def self.down
    drop_table :club_affiliations
  end
end
