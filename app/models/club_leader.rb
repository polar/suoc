class ClubLeader < ActiveRecord::Base
  belongs_to :member,     :class_name => "ClubMember"
  belongs_to :leadership, :class_name => "ClubLeadership"

  validates_presence_of :member
  validates_presence_of :leadership
  
  validates_date :start_date
  validates_date :end_date
  
end
