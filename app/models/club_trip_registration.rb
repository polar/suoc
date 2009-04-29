class ClubTripRegistration < ActiveRecord::Base
  belongs_to :leader, :class_name => "ClubMember"
  belongs_to :leadership, :class_name => "ClubLeadership"
  has_and_belongs_to_many   :club_members, :uniq => true

  validates_presence_of :leader
  validates_presence_of :leadership
  validates_presence_of :trip_name
  validates_date :departure_date
  validates_date :return_date
  validates_presence_of :email
  validates_presence_of :location

  def submitted?
    !submit_date.nil?
  end
end
