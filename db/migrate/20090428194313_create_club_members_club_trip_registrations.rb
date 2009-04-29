class CreateClubMembersClubTripRegistrations < ActiveRecord::Migration
  def self.up
    create_table :club_members_club_trip_registrations, :id => false do |t|
      t.references :club_member
      t.references :club_trip_registration
    end
  end

  def self.down
    drop_table :club_members_club_trip_registrations
  end
end
