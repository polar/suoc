class ClubMembership < ActiveRecord::Base
  belongs_to  :member,      :class_name => "ClubMember"
  belongs_to  :acct_transaction, :class_name => "AcctTransaction"
  belongs_to  :member_type, :class_name => "ClubMembershipType"

  validates_presence_of :member
  validates_presence_of :acct_transaction
  validates_presence_of :member_type
  validates_presence_of :year

  def start_date
    if member_type.name == "Spring"
      Date.parse("#{year}-01-01")
    elsif member_type.name == "Year"
      Date.parse("#{year}-09-01")
    else
      raise "Illegal Member Type"
    end
  end

  def end_date
    if member_type.name = "Spring"
      Date.parse("#{year}-09-01")
    elsif member_type.name == "Year"
      Date.parse("#{year+1}-09-01")
    else
      raise "Illegal Member Type"
    end
  end

  def current?
    start_date <= Date.today <= end_date
  end
end
