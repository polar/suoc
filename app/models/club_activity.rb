#
# Club Activity
#   This is the activity division in the club.
#
class ClubActivity < ActiveRecord::Base
  has_many :leaderships, :class_name => "ClubLeadership", :foreign_key => "activity_id"

  validates_uniqueness_of :name
end
