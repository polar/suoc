class ClubMemberStatus < ActiveRecord::Base
  validates_presence_of :name
  
  validates_uniqueness_of :name
  
  acts_as_enumerated

end