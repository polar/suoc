class CreateClubChairs < ActiveRecord::Migration
  def self.up
    create_table :club_chairs do |t|
      
      t.references   :club_member
      t.references   :club_chairmanship

      t.date         :start_date
      t.date         :end_date
      
      t.timestamps
    end
  end

  def self.down
    drop_table :club_chairs
  end
end
