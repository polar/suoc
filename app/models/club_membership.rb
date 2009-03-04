class ClubMembership < ActiveRecord::Base
  belongs_to  :member,      :class_name => "ClubMember"
  belongs_to  :acct_transaction, :class_name => "AcctTransaction"
  belongs_to  :member_type, :class_name => "ClubMembershipType"
  
  #validates_presence_of :member, :acct_transaction, :member_type, :year

  def current?
    if member_type.name == "Year"
      Date.today <= acct_transaction.date + 1.year
    else
      if Date.today.year == year
        if member_type.name == "Spring"
          Date.today.month < 6
        else # Fall
          Date.today.month > 8
        end
     else
       false
     end
   end
 end
end
