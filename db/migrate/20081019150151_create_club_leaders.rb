class CreateClubLeaders < ActiveRecord::Migration
  def self.up
    create_table :club_leaders do |t|
      
      t.references   :member     # ClubMember
      t.references   :leadership # ClubLeadership

      t.date         :start_date
      t.date         :end_date
      
      t.timestamps
    end
  end

  def self.down
    drop_table :club_leaders
  end
end
