class ClubLeader < ActiveRecord::Base
  belongs_to :member,     :class_name => "ClubMember"
  belongs_to :leadership, :class_name => "ClubLeadership"

  validates_presence :member
  validates_presence :leadership
  
  validates_date :start_date
  validates_date :end_date
  
  validates_uniquness_of :member, :scope => :leadership_id,
       message => "#{member.name} is already a leader in #{leadership.name}"
end
