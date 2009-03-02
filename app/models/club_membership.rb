class ClubMembership < ActiveRecord::Base
  belongs_to  :member,      :class_name => "ClubMember"
  belongs_to  :acct_transaction, :class_name => "AcctTransaction"
  belongs_to  :member_type, :class_name => "ClubMembershipType"
  
  #validates_presence_of :member, :acct_transaction, :member_type, :year
  
end
