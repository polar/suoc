class AddClubAffiliationRequiresMemberid < ActiveRecord::Migration
  def self.up
    change_table :club_affiliations do |t|
      t.boolean :requires_memberid, :default => true
    end
  end

  def self.down
    change_table :club_affiliations do |t|
      t.remove :requires_memberid
    end
  end
end
