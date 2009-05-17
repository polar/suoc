class AddVerifyToClubLeader < ActiveRecord::Migration
  def self.up
    change_table :club_leaders do |t|
      t.references :verified_by
      t.date       :verified_date
    end
  end

  def self.down
    change_table :club_leaders do |t|
      t.remove_references :verified_by
      t.remove            :verified_date
    end
  end
end
