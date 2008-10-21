class ClubOfficer < ActiveRecord::Base
  belongs_to :member, :class_name => "ClubMember"
  belongs_to :office, :class_name => "ClubOffice"

  validates_date :start_date
  validates_date :end_date
  
  def current?
    start_date <= Date.today && Date.today <= end_date
  end
end
