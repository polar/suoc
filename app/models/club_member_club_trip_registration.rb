class ClubMemberClubTripRegistration < ActiveRecord::Base
  belongs_to :club_member
  belongs_to :club_trip_registration
  
  validates_presence_of :club_member_id, :club_trip_registration_id
  validates_uniqueness_of :club_member_id, :scope => :club_trip_registration_id
  validates_uniqueness_of :club_trip_registration_id, :scope => :club_member_id
end
