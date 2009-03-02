class CreateClubMembers < ActiveRecord::Migration
  def self.up
    create_table :club_members do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :club_members
  end
end
