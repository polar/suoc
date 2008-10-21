class CreateClubLeaderships < ActiveRecord::Migration
  def self.up
    create_table :club_leaderships do |t|
      t.string      :name
      t.text        :description, :default => ""
      
      t.references  :activity  # ClubActivity

      t.timestamps
    end
  end

  def self.down
    drop_table :club_leaderships
  end
end
