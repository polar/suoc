class CreateClubOfficers < ActiveRecord::Migration
  def self.up
    create_table :club_officers do |t|
      
      t.references   :member  # ClubMemmber
      t.references   :office  # ClubOffice

      t.date         :start_date
      t.date         :end_date
      
      t.timestamps
    end
  end

  def self.down
    drop_table :club_officers
  end
end
