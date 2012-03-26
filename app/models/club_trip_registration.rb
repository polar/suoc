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

  def days
      ret = ((return_date - departure_date)).floor + 1
      if ret < 0 || ret > 10 # Its a mistake, so say it's 1
          ret = 1
      end
      ret
  end

  def people_days
      days * club_members.count
  end

  def submitted?
    !submit_date.nil?
  end

  private

  def abs(x)
      x < 0  ? -x : x
  end
end
