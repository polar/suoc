class ClubOfficer < ActiveRecord::Base
  belongs_to :member, :class_name => "ClubMember"
  belongs_to :office, :class_name => "ClubOffice"

  validates_presence_of :office
  validates_presence_of :member

  validates_date :start_date, :before => Proc.new { Date.today }
  validates_date :end_date, :after => :start_date

  def current?
    start_date <= Date.today && Date.today <= end_date
  end
end
