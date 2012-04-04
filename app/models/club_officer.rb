class ClubOfficer < ActiveRecord::Base
  belongs_to :member, :class_name => "ClubMember"
  belongs_to :office, :class_name => "ClubOffice"

  validates_presence_of :office
  validates_presence_of :member

  # We need to validates else it parses the date with the day first.
  validates_date :start_date
  validates_date :end_date
  validates_date :start_date, :before => Proc.new { Date.today }
  validates_date :end_date, :after => :start_date

  def current?
    start_date <= Date.today && Date.today <= end_date
  end
end
