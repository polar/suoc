class ClubMembership < ActiveRecord::Base
  belongs_to  :member,      :class_name => "ClubMember"
  belongs_to  :transaction, :class_name => "AcctTransaction"
  belogns_to  :member_type, :class_name => "ClubMemberType"
  
  validates_presence_of :member, :transaction, :member_type, :year
  
end
